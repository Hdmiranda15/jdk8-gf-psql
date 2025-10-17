#!/bin/bash

# GlassFish settings
GLASSFISH_VERSION="7.0.25"
GLASSFISH_URL="https://repo1.maven.org/maven2/org/glassfish/main/distributions/glassfish/${GLASSFISH_VERSION}/glassfish-${GLASSFISH_VERSION}.zip"
INSTALL_DIR="$(pwd)/glassfish_server"
GLASSFISH_HOME="${INSTALL_DIR}/glassfish7"
ZIP_FILE="${INSTALL_DIR}/glassfish.zip"
PG_DRIVER_PATH="${INSTALL_DIR}/postgresql-42.7.8.jar"

# Function to download GlassFish and PostgreSQL driver
download_dependencies() {
    echo "Creating installation directory..."
    mkdir -p "${INSTALL_DIR}"

    echo "Downloading GlassFish..."
    wget -q "${GLASSFISH_URL}" -O "${ZIP_FILE}"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download GlassFish."
        exit 1
    fi

    echo "Downloading PostgreSQL JDBC Driver..."
    wget -q "https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.8/postgresql-42.7.8.jar" -O "${PG_DRIVER_PATH}"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download PostgreSQL JDBC Driver."
        exit 1
    fi
}

# Function to unzip GlassFish
unzip_glassfish() {
    echo "Unzipping GlassFish..."
    unzip -q "${ZIP_FILE}" -d "${INSTALL_DIR}"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to unzip GlassFish."
        exit 1
    fi
}

# Function to start GlassFish
start_glassfish() {
    if [ -d "${GLASSFISH_HOME}" ]; then
        echo "Starting GlassFish..."
        "${GLASSFISH_HOME}/bin/asadmin" start-domain domain1
        if [ $? -ne 0 ]; then
            echo "Error: Failed to start GlassFish."
            exit 1
        fi
    else
        echo "GlassFish is not installed. Please run the setup command first."
        exit 1
    fi
}

# Function to stop GlassFish
stop_glassfish() {
    if [ -d "${GLASSFISH_HOME}" ]; then
        echo "Stopping GlassFish..."
        "${GLASSFISH_HOME}/bin/asadmin" stop-domain domain1
        if [ $? -ne 0 ]; then
            echo "Error: Failed to stop GlassFish."
            exit 1
        fi
    else
        echo "GlassFish is not installed."
    fi
}

# Function to create JDBC connection pool
create_jdbc_connection_pool() {
    echo "Creating JDBC Connection Pool..."
    "${GLASSFISH_HOME}/bin/asadmin" create-jdbc-connection-pool \
        --datasourceclassname org.postgresql.ds.PGSimpleDataSource \
        --restype javax.sql.DataSource \
        --steadypoolsize 8 \
        --maxpoolsize 32 \
        --idletimeout 300 \
        --property "user=hDB:password=pas!@#:url=jdbc\:postgresql\://localhost\:5432/NombreDB" \
        PostgresConnectionPool
}

# Function to create JDBC resource
create_jdbc_resource() {
    echo "Creating JDBC Resource..."
    "${GLASSFISH_HOME}/bin/asadmin" create-jdbc-resource \
        --connectionpoolid PostgresConnectionPool \
        jdbc/postgres
}

# Function to deploy WAR
deploy_war() {
    echo "Deploying WAR..."
    "${GLASSFISH_HOME}/bin/asadmin" deploy "$1"
}

# Function to undeploy WAR
undeploy_war() {
    echo "Undeploying WAR..."
    "${GLASSFISH_HOME}/bin/asadmin" undeploy "$1"
}

# Function to delete JDBC resource
delete_jdbc_resource() {
    echo "Deleting JDBC Resource..."
    "${GLASSFISH_HOME}/bin/asadmin" delete-jdbc-resource jdbc/postgres
}

# Function to delete JDBC connection pool
delete_jdbc_connection_pool() {
    echo "Deleting JDBC Connection Pool..."
    "${GLASSFISH_HOME}/bin/asadmin" delete-jdbc-connection-pool PostgresConnectionPool
}


# Main script logic
case "$1" in
    setup)
        if [ ! -d "${GLASSFISH_HOME}" ]; then
            download_dependencies
            unzip_glassfish
            start_glassfish
            "${GLASSFISH_HOME}/bin/asadmin" add-library "${PG_DRIVER_PATH}"
            create_jdbc_connection_pool
            create_jdbc_resource
            deploy_war "$(pwd)/sample.war"
        else
            echo "GlassFish is already installed."
        fi
        ;;
    start)
        start_glassfish
        ;;
    stop)
        stop_glassfish
        ;;
    deploy)
        if [ -z "$2" ]; then
            echo "Usage: $0 deploy <path_to_war>"
            exit 1
        fi
        deploy_war "$2"
        ;;
    clean)
        undeploy_war "sample"
        delete_jdbc_resource
        delete_jdbc_connection_pool
        ;;
    *)
        echo "Usage: $0 {setup|start|stop|deploy <path_to_war>|clean}"
        exit 1
        ;;
esac

exit 0