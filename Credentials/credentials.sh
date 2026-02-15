setup_credentials() {
    cred_file="$(pwd)/Credentials/credentials.txt"

    warn "Configuring Elasticsearch settings..."
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

    echo ""

    warn "Configuring PHP settings..."
    
    # 1️⃣ Ask user for PHP version
    read -rp "Enter PHP version to install (e.g., 8.1, 8.2, 8.3): " PHP_VER
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

    # Save to credentials.sh
    cat > "$cred_file" <<EOF
export MYSQL_ROOT_PASS="$MYSQL_ROOT_PASS"
export MYSQL_DB_NAME="$MYSQL_DB_NAME"
export MYSQL_DB_USER="$MYSQL_DB_USER"
export MYSQL_DB_PASS="$MYSQL_DB_PASS"
EOF

    success "Credentials saved to $cred_file"
}