#!/bin/bash

setup_credentials() {
    cred_file="$(pwd)/Credentials/credentials.txt"

    warn "Configuring Elasticsearch settings..."

    read -rp "Enter Elasticsearch version to install (e.g., 7, 8) [default: 8]: " VER_ES
    VER_ES=${VER_ES:-8}
    
    read -rp "Enter node.name [default: My First Node]: " NODE_NAME
    NODE_NAME=${NODE_NAME:-"My First Node"}

    read -rp "Enter cluster.name [default: my-application]: " CLUSTER_NAME
    CLUSTER_NAME=${CLUSTER_NAME:-"my-application"}

    read -rp "Enter network.host [default: 127.0.0.1]: " NETWORK_HOST
    NETWORK_HOST=${NETWORK_HOST:-"127.0.0.1"}

    read -rp "Enter http.port [default: 9200]: " HTTP_PORT
    HTTP_PORT=${HTTP_PORT:-9200}
    echo ""

    read -rp "Enter minimum JVM heap size (e.g., 512m) [default: 256m]: " HEAP_MIN
    HEAP_MIN=${HEAP_MIN:-256m}

    read -rp "Enter maximum JVM heap size (e.g., 2g) [default: 256m]: " HEAP_MAX
    HEAP_MAX=${HEAP_MAX:-256m}

    warn "Configuring PHP settings..."
    
    # 1️⃣ Ask user for PHP version
    read -rp "Enter PHP version to install (e.g., 8.1, 8.2, 8.3): " PHP_VER
    echo ""

    warn "Magento2 version selection..."
    read -rp "Enter magento version (e.g., 2.4.6, 2.4.7, 2.4.8) [default: 2.4.8]: " MAG_VER
    MAG_VER=${MAG_VER:-2.4.8}
    echo ""


    # If credentials exist → load them
    if [[ -f "$cred_file" ]]; then
        warn "Loading existing credentials..."
        source "$cred_file"
        return 0
    fi

    warn "Creating credentials file..."

    read -rsp "Enter MySQL ROOT password: " MYSQL_ROOT_PASS
    echo ""
    read -rp "Enter database name: " MYSQL_DB_NAME
    read -rp "Enter username: " MYSQL_DB_USER
    read -rsp "Enter user password: " MYSQL_DB_PASS
    echo ""
    echo ""
    warn "Magento setup configuration"

    read -rp "Base URL [http://test.com]: " BASE_URL
    BASE_URL=${BASE_URL:-http://test.com}

    read -rp "Admin email [admin@example.com]: " ADMIN_EMAIL
    ADMIN_EMAIL=${ADMIN_EMAIL:-admin@example.com}
    
    read -rp "Admin username [admin]: " ADMIN_USER
    ADMIN_USER=${ADMIN_USER:-admin}

    read -rsp "Admin password [admin@123]: " ADMIN_PASS
    ADMIN_PASS=${ADMIN_PASS:-admin@123}
    echo ""

    # Save to credentials.sh
    cat > "$cred_file" <<EOF
export MYSQL_ROOT_PASS="$MYSQL_ROOT_PASS"
export MYSQL_DB_NAME="$MYSQL_DB_NAME"
export MYSQL_DB_USER="$MYSQL_DB_USER"
export MYSQL_DB_PASS="$MYSQL_DB_PASS"
export BASE_URL="$BASE_URL"
export ADMIN_USER="$ADMIN_USER"
export ADMIN_PASS="$ADMIN_PASS"
EOF

    success "Credentials saved to $cred_file"
}