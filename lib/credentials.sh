setup_credentials() {
    cred_file="$(pwd)/lib/credentials.txt"
    
    # 1️⃣ Ask user for PHP version
    read -rp "Enter PHP version to install (e.g., 8.1, 8.2, 8.3): " PHP_VER
    
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