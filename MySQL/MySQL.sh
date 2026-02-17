#!/bin/bash

install_mysql() {
    # Skip if MySQL 8 exists
    if command -v mysql >/dev/null 2>&1 && mysql --version | grep -qE "Ver 8\."; then
        success "✔ MySQL 8 is already installed"
    else
        warn "⚠ Installing MySQL 8..."

        local mysql_repo_pkg="/tmp/mysql-apt-config.deb"

        retry 3 wget -qO "$mysql_repo_pkg" \
            https://dev.mysql.com/get/mysql-apt-config_0.8.36-1_all.deb || return 1

        export DEBIAN_FRONTEND=noninteractive
        dpkg -i "$mysql_repo_pkg" >/dev/null 2>&1

        run_step "Updating APT cache" retry 3 apt-get update || return 1
        run_step "Installing MySQL server" retry 3 apt-get install -y mysql-server || return 1

        success "✔ MySQL 8 installed successfully"
    fi

    warn "⚠ Checking MySQL root authentication..."

    if sudo mysql -e "SELECT 1;" &>/dev/null; then
       success "✔ MySQL root login works. Skipping password configuration."
    else
        warn "⚠ Root login failed. Configuring MySQL root password..."

    mysql <<MYSQL_ROOT
ALTER USER 'root'@'localhost'
IDENTIFIED WITH caching_sha2_password
BY '$MYSQL_ROOT_PASS';
FLUSH PRIVILEGES;
MYSQL_ROOT

     if mysql -u root -p"$MYSQL_ROOT_PASS" -e "SELECT 1;" &>/dev/null; then
        success "✔ MySQL root password configured successfully."
    else
        error "✖ Failed to configure MySQL root password!"
        return 1
    fi
fi


    # Create database + user (only if MySQL login works)

    warn "⚠ Checking MySQL access before creating database..."

    if ! mysql -u root -p"$MYSQL_ROOT_PASS" -e "SELECT 1;" &>/dev/null; then
        error "✖ Cannot login to MySQL as root. Skipping DB setup."
        return 1
    fi

    warn "⚠ Creating database and user..."

    mysql -u root -p"$MYSQL_ROOT_PASS" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DB_NAME\`;
CREATE USER IF NOT EXISTS '$MYSQL_DB_USER'@'localhost' IDENTIFIED BY '$MYSQL_DB_PASS';
GRANT ALL PRIVILEGES ON \`$MYSQL_DB_NAME\`.* TO '$MYSQL_DB_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

    # Verify DB access with new user
    if mysql -u "$MYSQL_DB_USER" -p"$MYSQL_DB_PASS" -e "USE \`$MYSQL_DB_NAME\`;" &>/dev/null; then
        success "✔ Database and user configured successfully."
    else
        error "✖ Database/user verification failed!"
        return 1
fi


        # Enable log_bin_trust_function_creators for Magento
    warn "⚠ Configuring MySQL for Magento triggers..."

    local mysql_conf="/etc/mysql/mysql.conf.d/mysqld.cnf"
    local config_changed=false

    # Add setting only if not already present
    if ! grep -q "log_bin_trust_function_creators" "$mysql_conf"; then
        echo "" >> "$mysql_conf"
        echo "[mysqld]" >> "$mysql_conf"
        echo "log_bin_trust_function_creators=1" >> "$mysql_conf"
            config_changed=true
            success "✔ MySQL config updated"
    else
        success "✔ MySQL config already contains required setting"
    fi


    # Restart only if config changed

    if [ "$config_changed" = true ]; then
        run_step "Restarting MySQL service" systemctl restart mysql || return 1
    else
        warn "⚠ Skipping MySQL restart (no changes detected)"
    fi

    success "✔ MySQL configured for Magento successfully."

}