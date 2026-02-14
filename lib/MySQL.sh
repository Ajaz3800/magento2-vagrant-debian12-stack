#!/bin/bash

install_mysql() {
    # Skip if MySQL 8 exists
    if command -v mysql >/dev/null 2>&1 && mysql --version | grep -qE "Ver 8\."; then
        success "MySQL 8 is already installed"
    else
        warn "Installing MySQL 8..."

        local mysql_repo_pkg="/tmp/mysql-apt-config.deb"

        retry 3 wget -qO "$mysql_repo_pkg" \
            https://dev.mysql.com/get/mysql-apt-config_0.8.26-1_all.deb || return 1

        export DEBIAN_FRONTEND=noninteractive
        dpkg -i "$mysql_repo_pkg" >/dev/null 2>&1

        retry 3 apt-get update || return 1
        retry 3 apt-get install -y mysql-server || return 1

        success "MySQL 8 installed successfully"
    fi

    echo ""
    warn "=== MySQL Database Configuration ==="

    # Ask user input
    read -rp "Enter database name: " DB_NAME
    read -rp "Enter MySQL username: " DB_USER
    read -rsp "Enter password: " DB_PASS
    echo ""

    # Create DB and user
    mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

    if [[ $? -eq 0 ]]; then
        success "Database and user created successfully"
    else
        error "Failed to configure MySQL database"
        return 1
    fi
}
