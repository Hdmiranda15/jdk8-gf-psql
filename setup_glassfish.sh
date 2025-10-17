#!/bin/bash
# setup_glassfish.sh
# Instala y configura GlassFish 7, un pool de conexiones JDBC para PostgreSQL y despliega una aplicación.
# Diseñado para ser idempotente.

set -euo pipefail

# --- COLORES Y FUNCIONES DE LOG ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# =================================================================
# CONFIGURACIÓN
# =================================================================
GLASSFISH_VERSION="7.0.25"
GLASSFISH_URL="https://repo1.maven.org/maven2/org/glassfish/main/distributions/glassfish/${GLASSFISH_VERSION}/glassfish-${GLASSFISH_VERSION}.zip"
INSTALL_DIR="$(pwd)/glassfish_server"
GLASSFISH_HOME="${INSTALL_DIR}/glassfish7"
ZIP_FILE="${INSTALL_DIR}/glassfish.zip"
PG_DRIVER_URL="https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.8/postgresql-42.7.8.jar"
PG_DRIVER_PATH="${INSTALL_DIR}/postgresql-42.7.8.jar"
DOMAIN_NAME="domain1"
ADMIN_PORT="4848"
JDBC_POOL_NAME="PostgresConnectionPool"
JDBC_RESOURCE_NAME="jdbc/postgres"

# =================================================================
# FUNCIONES AUXILIARES
# =================================================================

is_domain_running() {
    if [ -f "${GLASSFISH_HOME}/glassfish/domains/${DOMAIN_NAME}/config/pid" ]; then
        PID=$(cat "${GLASSFISH_HOME}/glassfish/domains/${DOMAIN_NAME}/config/pid")
        if ps -p $PID > /dev/null; then
            return 0 # 0 means true in bash
        fi
    fi
    return 1 # 1 means false
}

# =================================================================
# FUNCIONES PRINCIPALES
# =================================================================

download_dependencies() {
    if [ ! -d "${INSTALL_DIR}" ]; then
        log "Creando directorio de instalación en '${INSTALL_DIR}'..."
        mkdir -p "${INSTALL_DIR}"
    fi

    if [ ! -f "${ZIP_FILE}" ]; then
        log "Descargando GlassFish v${GLASSFISH_VERSION}..."
        wget -q -O "${ZIP_FILE}" "${GLASSFISH_URL}"
        log "✅ GlassFish descargado."
    else
        log "✅ GlassFish ya ha sido descargado."
    fi

    if [ ! -f "${PG_DRIVER_PATH}" ]; then
        log "Descargando driver JDBC de PostgreSQL..."
        wget -q -O "${PG_DRIVER_PATH}" "${PG_DRIVER_URL}"
        log "✅ Driver JDBC de PostgreSQL descargado."
    else
        log "✅ Driver JDBC de PostgreSQL ya ha sido descargado."
    fi
}

unzip_glassfish() {
    if [ ! -d "${GLASSFISH_HOME}" ]; then
        log "Descomprimiendo GlassFish..."
        unzip -q -o "${ZIP_FILE}" -d "${INSTALL_DIR}"
        log "✅ GlassFish descomprimido."
    else
        log "✅ GlassFish ya está descomprimido."
    fi
}

start_glassfish() {
    if is_domain_running; then
        log "✅ El dominio '${DOMAIN_NAME}' ya está en ejecución."
        return
    fi
    log "Iniciando el dominio '${DOMAIN_NAME}' de GlassFish..."
    "${GLASSFISH_HOME}/bin/asadmin" start-domain "${DOMAIN_NAME}"
    log "✅ Dominio iniciado."
}

stop_glassfish() {
    if ! is_domain_running; then
        log "✅ El dominio '${DOMAIN_NAME}' ya está detenido."
        return
    fi
    log "Deteniendo el dominio '${DOMAIN_NAME}' de GlassFish..."
    "${GLASSFISH_HOME}/bin/asadmin" stop-domain "${DOMAIN_NAME}"
    log "✅ Dominio detenido."
}

create_jdbc_connection_pool() {
    local DB_USER="$1"
    local DB_PASS="$2"
    local DB_HOST="$3"
    local DB_PORT="$4"
    local DB_NAME="$5"

    start_glassfish # Ensure domain is running

    log "Verificando si el pool de conexiones JDBC '${JDBC_POOL_NAME}' ya existe..."
    if ! "${GLASSFISH_HOME}/bin/asadmin" list-jdbc-connection-pools | grep -q "${JDBC_POOL_NAME}"; then
        log "Creando pool de conexiones JDBC '${JDBC_POOL_NAME}'..."
        "${GLASSFISH_HOME}/bin/asadmin" create-jdbc-connection-pool \
            --datasourceclassname org.postgresql.ds.PGSimpleDataSource \
            --restype javax.sql.DataSource \
            --steadypoolsize 8 \
            --maxpoolsize 32 \
            --idletimeout 300 \
            --property "user=${DB_USER}:password=${DB_PASS}:url=jdbc\:postgresql\://${DB_HOST}\:${DB_PORT}/${DB_NAME}" \
            "${JDBC_POOL_NAME}"
        log "✅ Pool de conexiones creado."
    else
        log "✅ El pool de conexiones '${JDBC_POOL_NAME}' ya existe."
    fi
}

create_jdbc_resource() {
    start_glassfish # Ensure domain is running

    log "Verificando si el recurso JNDI '${JDBC_RESOURCE_NAME}' ya existe..."
    if ! "${GLASSFISH_HOME}/bin/asadmin" list-jdbc-resources | grep -q "${JDBC_RESOURCE_NAME}"; then
        log "Creando recurso JNDI '${JDBC_RESOURCE_NAME}'..."
        "${GLASSFISH_HOME}/bin/asadmin" create-jdbc-resource \
            --connectionpoolid "${JDBC_POOL_NAME}" \
            "${JDBC_RESOURCE_NAME}"
        log "✅ Recurso JNDI creado."
    else
        log "✅ El recurso JNDI '${JDBC_RESOURCE_NAME}' ya existe."
    fi
}

deploy_war() {
    local WAR_PATH="$1"
    local APP_NAME=$(basename "$WAR_PATH" .war)

    start_glassfish # Ensure domain is running

    log "Verificando si la aplicación '${APP_NAME}' ya está desplegada..."
    if ! "${GLASSFISH_HOME}/bin/asadmin" list-applications | grep -q "${APP_NAME}"; then
        log "Desplegando la aplicación desde '${WAR_PATH}'..."
        "${GLASSFISH_HOME}/bin/asadmin" deploy "${WAR_PATH}"
        log "✅ Aplicación '${APP_NAME}' desplegada."
    else
        log "✅ La aplicación '${APP_NAME}' ya está desplegada."
    fi
}

undeploy_war() {
    local APP_NAME="$1"

    start_glassfish # Ensure domain is running

    log "Verificando si la aplicación '${APP_NAME}' está desplegada antes de eliminarla..."
    if "${GLASSFISH_HOME}/bin/asadmin" list-applications | grep -q "${APP_NAME}"; then
        log "Eliminando despliegue de la aplicación '${APP_NAME}'..."
        "${GLASSFISH_HOME}/bin/asadmin" undeploy "${APP_NAME}"
        log "✅ Aplicación '${APP_NAME}' eliminada."
    else
        log "✅ La aplicación '${APP_NAME}' no se encuentra desplegada."
    fi
}

delete_jdbc_resource() {
    start_glassfish # Ensure domain is running

    log "Verificando si el recurso JNDI '${JDBC_RESOURCE_NAME}' existe antes de eliminarlo..."
    if "${GLASSFISH_HOME}/bin/asadmin" list-jdbc-resources | grep -q "${JDBC_RESOURCE_NAME}"; then
        log "Eliminando el recurso JNDI '${JDBC_RESOURCE_NAME}'..."
        "${GLASSFISH_HOME}/bin/asadmin" delete-jdbc-resource "${JDBC_RESOURCE_NAME}"
        log "✅ Recurso JNDI eliminado."
    else
        log "✅ El recurso JNDI '${JDBC_RESOURCE_NAME}' no existe."
    fi
}

delete_jdbc_connection_pool() {
    start_glassfish # Ensure domain is running

    log "Verificando si el pool de conexiones '${JDBC_POOL_NAME}' existe antes de eliminarlo..."
    if "${GLASSFISH_HOME}/bin/asadmin" list-jdbc-connection-pools | grep -q "${JDBC_POOL_NAME}"; then
        log "Eliminando el pool de conexiones '${JDBC_POOL_NAME}'..."
        "${GLASSFISH_HOME}/bin/asadmin" delete-jdbc-connection-pool "${JDBC_POOL_NAME}"
        log "✅ Pool de conexiones eliminado."
    else
        log "✅ El pool de conexiones '${JDBC_POOL_NAME}' no existe."
    fi
}

# =================================================================
# LÓGICA PRINCIPAL DEL SCRIPT
# =================================================================
main() {
    case "$1" in
        setup)
            if [ $# -ne 6 ]; then
                error "Uso: $0 setup <db_user> <db_password> <db_host> <db_port> <db_name>"
            fi
            log "🚀 Iniciando setup completo de GlassFish..."
            download_dependencies
            unzip_glassfish
            start_glassfish
            "${GLASSFISH_HOME}/bin/asadmin" add-library "${PG_DRIVER_PATH}"
            create_jdbc_connection_pool "$2" "$3" "$4" "$5" "$6"
            create_jdbc_resource
            log "🎉 ¡Setup de GlassFish completado!"
            log "   El servidor está en ejecución. Ahora puedes desplegar tu aplicación con el comando 'deploy'."
            ;;
        start)
            start_glassfish
            ;;
        stop)
            stop_glassfish
            ;;
        deploy)
            if [ -z "$2" ]; then
                error "Uso: $0 deploy <ruta_al_war>"
            fi
            deploy_war "$2"
            ;;
        clean)
            if [ -z "$2" ]; then
                error "Uso: $0 clean <nombre_app>"
            fi
            undeploy_war "$2"
            delete_jdbc_resource
            delete_jdbc_connection_pool
            log "🧼 Limpieza de configuración completada."
            ;;
        *)
            echo "Uso: $0 {setup <db_user> <db_pass> <db_host> <db_port> <db_name>|start|stop|deploy <war_path>|clean <app_name>}"
            exit 1
            ;;
    esac
}

main "$@"