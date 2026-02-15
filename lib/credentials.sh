setup_credentials() {
    local cred_file="./lib/credentials.txt"

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
#!/bin/bash

export MYSQL_ROOT_PASS="$MYSQL_ROOT_PASS"
export MYSQL_DB_NAME="$MYSQL_DB_NAME"
export MYSQL_DB_USER="$MYSQL_DB_USER"
export MYSQL_DB_PASS="$MYSQL_DB_PASS"
EOF

    chmod 600 "$cred_file"

    success "Credentials saved to $cred_file"
}