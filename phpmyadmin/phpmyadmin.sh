#!/bin/bash

install_phpmyadmin() {

    local PMA_VERSION="latest"
    local PMA_URL="https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz"
    local PMA_TAR="/tmp/phpmyadmin.tar.gz"
    local PMA_DIR=$(find /usr/share/phpmyadmin -maxdepth 1 -type d -name "phpMyAdmin-*" | head -n 1)
    local TMP_DIR="/var/lib/phpmyadmin/tmp"

    if [[ -d "$PMA_DIR" ]]; then
        success "phpMyAdmin is already installed"
        return 0
    fi

    warn "phpMyAdmin is not installed. Installing now..."

    # 1️⃣ Download phpMyAdmin
    run_step "Downloading phpMyAdmin" retry 3 wget -qO "$PMA_TAR" "$PMA_URL" || return 1

    # 2️⃣ Extract files
    run_step "Extracting phpMyAdmin" bash -c "
        mkdir -p $PMA_DIR &&
        tar xzf $PMA_TAR -C /usr/share &&
        mv /usr/share/phpMyAdmin-* $PMA_DIR
    " || return 1

    # 3️⃣ Create temp directory
    run_step "Creating temp directory" bash -c "
        mkdir -p $TMP_DIR &&
        chown -R www-data:www-data $TMP_DIR &&
        chmod 700 $TMP_DIR
    " || return 1

    # 4️⃣ Create config file

    
    if [[ -z "$PMA_DIR" ]]; then
        error "phpMyAdmin directory not found!"
        return 1
    fi

    # Create stable symlink
    ln -sfn "$PMA_DIR" /usr/share/phpmyadmin/current
    PMA_DIR="/usr/share/phpmyadmin/current"

    # Copy config
    if cp "$PMA_DIR/config.sample.inc.php" "$PMA_DIR/config.inc.php"; then
        success "phpMyAdmin configured successfully"
    else
        error "Failed to configure phpMyAdmin"
        return 1
    fi


    # 5️⃣ Permissions
    run_step "Setting permissions" bash -c "
        chown -R www-data:www-data $PMA_DIR &&
        chmod -R 755 $PMA_DIR
    " || return 1

    success "phpMyAdmin installed successfully"
}