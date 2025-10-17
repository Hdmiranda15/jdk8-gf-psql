#!/bin/bash
# PROJECT_BASE_STRUCTURE.sh
# Generates a standard Java EE project structure.
# Diseñado para ser idempotente: se puede ejecutar múltiples veces.

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
# CONFIGURACIÓN DE LA ESTRUCTURA DEL PROYECTO
# =================================================================
BASE_PACKAGE_PATH="src/main/java/com/example/app"
WEBAPP_PATH="src/main/webapp"
RESOURCES_PATH="src/main/resources"

MODULES=("users" "wallet" "trips" "fleet" "routes" "history" "reports" "shared")
SUB_PACKAGES=("bean" "dao" "entity" "service")
COMMON_PACKAGES=("exception" "security" "util")

log "🚀 Iniciando la creación de la estructura base del proyecto..."

# =================================================================
# 1. CREACIÓN DE PAQUETES JAVA
# =================================================================
log "Generando estructura de paquetes Java en '$BASE_PACKAGE_PATH'..."
for module in "${MODULES[@]}"; do
    for sub_package in "${SUB_PACKAGES[@]}"; do
        mkdir -p "${BASE_PACKAGE_PATH}/${module}/${sub_package}"
    done
done

for common_package in "${COMMON_PACKAGES[@]}"; do
    mkdir -p "${BASE_PACKAGE_PATH}/shared/${common_package}"
done

mkdir -p "$BASE_PACKAGE_PATH/trips/dto"
mkdir -p "$BASE_PACKAGE_PATH/reports/dto"
mkdir -p "$BASE_PACKAGE_PATH/api/resource"
mkdir -p "$BASE_PACKAGE_PATH/api/dto"
mkdir -p "$BASE_PACKAGE_PATH/api/exception"
log "✅ Estructura de paquetes Java creada."

# =================================================================
# 2. CREACIÓN DE ARCHIVOS .java VACÍOS
# =================================================================
log "Creando archivos .java vacíos..."
touch "$BASE_PACKAGE_PATH/users/bean/GestionUsuariosBean.java"
touch "$BASE_PACKAGE_PATH/users/bean/LoginBean.java"
touch "$BASE_PACKAGE_PATH/users/bean/RegistroBean.java"
touch "$BASE_PACKAGE_PATH/users/dao/RolDAO.java"
touch "$BASE_PACKAGE_PATH/users/dao/UsuarioDAO.java"
touch "$BASE_PACKAGE_PATH/users/entity/Rol.java"
touch "$BASE_PACKAGE_PATH/users/entity/Usuario.java"
touch "$BASE_PACKAGE_PATH/users/service/UsuarioService.java"
touch "$BASE_PACKAGE_PATH/wallet/bean/BilleteraBean.java"
touch "$BASE_PACKAGE_PATH/wallet/dao/TarjetaDAO.java"
touch "$BASE_PACKAGE_PATH/wallet/dao/TransaccionDAO.java"
touch "$BASE_PACKAGE_PATH/wallet/entity/Tarjeta.java"
touch "$BASE_PACKAGE_PATH/wallet/entity/TipoTransaccion.java"
touch "$BASE_PACKAGE_PATH/wallet/entity/Transaccion.java"
touch "$BASE_PACKAGE_PATH/wallet/service/BilleteraService.java"
touch "$BASE_PACKAGE_PATH/wallet/service/PasarelaPagoService.java"
touch "$BASE_PACKAGE_PATH/trips/bean/MapaTiempoRealBean.java"
touch "$BASE_PACKAGE_PATH/trips/bean/PlanificadorBean.java"
touch "$BASE_PACKAGE_PATH/trips/dto/UbicacionAutobusDTO.java"
touch "$BASE_PACKAGE_PATH/trips/entity/Viaje.java"
touch "$BASE_PACKAGE_PATH/trips/service/MonitoreoGPSService.java"
touch "$BASE_PACKAGE_PATH/trips/service/PlanificacionService.java"
touch "$BASE_PACKAGE_PATH/fleet/bean/GestionAutobusesBean.java"
touch "$BASE_PACKAGE_PATH/fleet/dao/AutobusDAO.java"
touch "$BASE_PACKAGE_PATH/fleet/entity/Autobus.java"
touch "$BASE_PACKAGE_PATH/fleet/service/FlotaService.java"
touch "$BASE_PACKAGE_PATH/routes/bean/GestionParadasBean.java"
touch "$BASE_PACKAGE_PATH/routes/bean/GestionRutasBean.java"
touch "$BASE_PACKAGE_PATH/routes/dao/ParadaDAO.java"
touch "$BASE_PACKAGE_PATH/routes/dao/RutaDAO.java"
touch "$BASE_PACKAGE_PATH/routes/dao/TarifaDAO.java"
touch "$BASE_PACKAGE_PATH/routes/entity/Parada.java"
touch "$BASE_PACKAGE_PATH/routes/entity/Ruta.java"
touch "$BASE_PACKAGE_PATH/routes/entity/Tarifa.java"
touch "$BASE_PACKAGE_PATH/routes/service/AdministracionRutasService.java"
touch "$BASE_PACKAGE_PATH/history/bean/HistorialBean.java"
touch "$BASE_PACKAGE_PATH/history/service/ConsultaHistorialService.java"
touch "$BASE_PACKAGE_PATH/reports/bean/DashboardBean.java"
touch "$BASE_PACKAGE_PATH/reports/dto/IngresosPorRutaDTO.java"
touch "$BASE_PACKAGE_PATH/reports/dto/PasajerosHoraPicoDTO.java"
touch "$BASE_PACKAGE_PATH/reports/service/AnaliticaService.java"
touch "$BASE_PACKAGE_PATH/shared/exception/BusinessLogicException.java"
touch "$BASE_PACKAGE_PATH/shared/security/AuthFilter.java"
touch "$BASE_PACKAGE_PATH/shared/util/DateUtil.java"
touch "$BASE_PACKAGE_PATH/shared/util/FacesUtil.java"
touch "$BASE_PACKAGE_PATH/api/resource/UsuarioResource.java"
touch "$BASE_PACKAGE_PATH/api/resource/BilleteraResource.java"
touch "$BASE_PACKAGE_PATH/api/resource/ViajeResource.java"
touch "$BASE_PACKAGE_PATH/api/resource/FlotaResource.java"
touch "$BASE_PACKAGE_PATH/api/resource/RutaResource.java"
touch "$BASE_PACKAGE_PATH/api/resource/HistorialResource.java"
touch "$BASE_PACKAGE_PATH/api/resource/ReporteResource.java"
touch "$BASE_PACKAGE_PATH/api/exception/RestExceptionHandler.java"
touch "$BASE_PACKAGE_PATH/api/dto/UsuarioDTO.java"
touch "$BASE_PACKAGE_PATH/api/dto/ViajeDTO.java"
log "✅ Archivos .java creados."

# =================================================================
# 3. CREACIÓN DE ESTRUCTURA WEB (XHTML Y RECURSOS)
# =================================================================
log "Generando estructura de carpetas y archivos .xhtml..."
mkdir -p "$WEBAPP_PATH/admin/flota"
mkdir -p "$WEBAPP_PATH/admin/paradas"
mkdir -p "$WEBAPP_PATH/admin/rutas"
mkdir -p "$WEBAPP_PATH/admin/usuarios"
mkdir -p "$WEBAPP_PATH/pasajero"
mkdir -p "$WEBAPP_PATH/resources/css"

touch "$WEBAPP_PATH/admin/dashboard.xhtml"
touch "$WEBAPP_PATH/admin/flota/formulario.xhtml"
touch "$WEBAPP_PATH/admin/flota/lista.xhtml"
touch "$WEBAPP_PATH/admin/paradas/formulario.xhtml"
touch "$WEBAPP_PATH/admin/paradas/lista.xhtml"
touch "$WEBAPP_PATH/admin/rutas/formulario.xhtml"
touch "$WEBAPP_PATH/admin/rutas/lista.xhtml"
touch "$WEBAPP_PATH/admin/usuarios/formulario.xhtml"
touch "$WEBAPP_PATH/admin/usuarios/lista.xhtml"
touch "$WEBAPP_PATH/pasajero/billetera.xhtml"
touch "$WEBAPP_PATH/pasajero/dashboard.xhtml"
touch "$WEBAPP_PATH/pasajero/historial.xhtml"
touch "$WEBAPP_PATH/pasajero/mapa.xhtml"
touch "$WEBAPP_PATH/pasajero/planificarViaje.xhtml"
touch "$WEBAPP_PATH/accesoDenegado.xhtml"
touch "$WEBAPP_PATH/error.xhtml"
touch "$WEBAPP_PATH/index.xhtml"
touch "$WEBAPP_PATH/login.xhtml"
touch "$WEBAPP_PATH/registro.xhtml"
touch "$WEBAPP_PATH/template.xhtml"
touch "$WEBAPP_PATH/resources/css/style.css"
log "✅ Archivos .xhtml y de recursos creados."

# =================================================================
# 4. CREACIÓN DE ARCHIVOS DE CONFIGURACIÓN
# =================================================================
log "Generando archivos de configuración (web.xml, persistence.xml)..."
mkdir -p "$WEBAPP_PATH/WEB-INF"
mkdir -p "$RESOURCES_PATH/META-INF"

cat <<EOF > "$WEBAPP_PATH/WEB-INF/web.xml"
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0">
    <servlet>
        <servlet-name>Faces Servlet</servlet-name>
        <servlet-class>jakarta.faces.webapp.FacesServlet</servlet-class>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>Faces Servlet</servlet-name>
        <url-pattern>*.xhtml</url-pattern>
    </servlet-mapping>
    <welcome-file-list>
        <welcome-file>index.xhtml</welcome-file>
    </welcome-file-list>
</web-app>
EOF

cat <<EOF > "$RESOURCES_PATH/META-INF/persistence.xml"
<?xml version="1.0" encoding="UTF-8"?>
<persistence version="3.0"
             xmlns="https://jakarta.ee/xml/ns/persistence"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="https://jakarta.ee/xml/ns/persistence https://jakarta.ee/xml/ns/persistence/persistence_3_0.xsd">
    <persistence-unit name="my-persistence-unit" transaction-type="JTA">
        <jta-data-source>jdbc/postgres</jta-data-source>
        <properties>
            <property name="jakarta.persistence.schema-generation.database.action" value="create"/>
        </properties>
    </persistence-unit>
</persistence>
EOF

touch "$WEBAPP_PATH/WEB-INF/beans.xml"
touch "$WEBAPP_PATH/WEB-INF/faces-config.xml"
log "✅ Archivos de configuración creados."

# =================================================================
# MENSAJE FINAL
# =================================================================
log ""
log "🎉 ¡La estructura del proyecto ha sido creada exitosamente!"
log "   Ahora puedes abrir este proyecto en tu IDE favorito."
log ""