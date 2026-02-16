#!/bin/bash

setup_credentials() {
    cred_file="$(pwd)/Credentials/credentials.txt"

    warn "⚠ Configuring Elasticsearch settings..."

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

    warn "⚠ Configuring PHP settings..."
    
    #  Ask user for PHP version
    read -rp "Enter PHP version to install (e.g., 8.1, 8.2, 8.3) [default: 8.3]: " PHP_VER
    PHP_VER=${PHP_VER:-8.3}
    echo ""

    warn "⚠ Domain for phpmyadmin..."
    
    #  Ask user for phpmyadmin Domain
    read -rp "Enter phpMyAdmin Domain (e.g., example.com) [default: example.com]: " PMA_URL
    PMA_URL=${PMA_URL:-"example.com"}
    echo ""

    warn "⚠ Magento2 configuration..."
    read -rp "Enter magento version (e.g., 2.4.6, 2.4.7, 2.4.8) [default: 2.4.8]: " MAG_VER
    MAG_VER=${MAG_VER:-2.4.8}
    read -rp "Enter Magento Domain [default: example.com]: " BASE_URL
    BASE_URL=${BASE_URL:-example.com}
    echo ""

     # --- Ask Magento credentials ---

    echo ""
    warn "⚠ Magento Marketplace authentication required"

    read -rp "Enter Magento Public Key: " MAGENTO_PUBLIC
    read -rsp "Enter Magento Private Key: " MAGENTO_PRIVATE
    echo ""


    # If credentials exist → load them
    if [[ -f "$cred_file" ]]; then
        warn "⚠ Loading existing credentials..."
        source "$cred_file"
        return 0
    fi

    warn "⚠ Creating credentials file..."

    read -rsp "Enter MySQL ROOT password [default: root@123]: " MYSQL_ROOT_PASS
    MYSQL_ROOT_PASS=${MYSQL_ROOT_PASS:-"root@123"}
    echo ""
    read -rp "Enter database name [default: test]: " MYSQL_DB_NAME
    MYSQL_DB_NAME=${MYSQL_DB_NAME:-"test"}
    read -rp "Enter username [default: test]: " MYSQL_DB_USER
    MYSQL_DB_USER=${MYSQL_DB_USER:-"test"}
    read -rsp "Enter user password [default: test@123]: " MYSQL_DB_PASS
    MYSQL_DB_PASS=${MYSQL_DB_PASS:-"test@123"}
    echo ""

    warn "⚠ Magento setup configuration"

    read -rp "Magento Admin email [default: admin@example.com]: " ADMIN_EMAIL
    ADMIN_EMAIL=${ADMIN_EMAIL:-admin@email.com}

    read -rp "Magento Admin username [default: admin]: " ADMIN_USER
    ADMIN_USER=${ADMIN_USER:-admin}

    read -rsp "Magento Admin password [default: admin@123]: " ADMIN_PASS
    ADMIN_PASS=${ADMIN_PASS:-admin@123}
    echo ""

    # Save to credentials.sh
    cat > "$cred_file" <<EOF
export MYSQL_ROOT_PASS="$MYSQL_ROOT_PASS"
export MYSQL_DB_NAME="$MYSQL_DB_NAME"
export MYSQL_DB_USER="$MYSQL_DB_USER"
export MYSQL_DB_PASS="$MYSQL_DB_PASS"
export ADMIN_EMAIL="$ADMIN_EMAIL"
export ADMIN_USER="$ADMIN_USER"
export ADMIN_PASS="$ADMIN_PASS"
EOF

    success "✔ Credentials saved to $cred_file"
}