#!/bin/bash

install_mysql() {
    # Skip if MySQL 8 exists
    if command -v mysql >/dev/null 2>&1 && mysql --version | grep -qE "Ver 8\."; then
        success "MySQL 8 is already installed"
    else
        warn "Installing MySQL 8..."

        local mysql_repo_pkg="/tmp/mysql-apt-config.deb"

        run_step "Downloading MySQL APT config package" retry 3 wget -qO "$mysql_repo_pkg" \
            https://dev.mysql.com/get/mysql-apt-config_0.8.36-1_all.deb || return 1

        export DEBIAN_FRONTEND=noninteractive
        dpkg -i "$mysql_repo_pkg" >/dev/null 2>&1

         run_step "Updating APT cache" retry 3 apt-get update || return 1
        run_step "Installing MySQL server" retry 3 apt-get install -y mysql-server || return 1

        success "MySQL 8 installed successfully"
    fi
 # 3️⃣ Configure MySQL root password
    warn "Configuring MySQL root user..."
    mysql <<MYSQL_ROOT
ALTER USER 'root'@'localhost'
IDENTIFIED WITH caching_sha2_password
BY '$MYSQL_ROOT_PASS';
FLUSH PRIVILEGES;
MYSQL_ROOT

    if [[ $? -ne 0 ]]; then
        error "Failed to configure MySQL root password"
        return 1
    fi

    success "Root password configured"

     # 4️⃣ Create database + user
    warn "Creating database and user..."
    mysql -u root -p"$MYSQL_ROOT_PASS" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DB_NAME\`;
CREATE USER IF NOT EXISTS '$MYSQL_DB_USER'@'localhost' IDENTIFIED BY '$MYSQL_DB_PASS';
GRANT ALL PRIVILEGES ON \`$MYSQL_DB_NAME\`.* TO '$MYSQL_DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

    if [[ $? -eq 0 ]]; then
        success "Database and user created successfully"
    else
        error "Failed to configure MySQL database"
        return 1
    fi
}