#!/bin/bash

install_phpmyadmin() {

    local PMA_URL="https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz"
    local PMA_TAR="/tmp/phpmyadmin.tar.gz"
    local BASE_DIR="/var/www/html"
    local TMP_DIR="/var/lib/phpmyadmin/tmp"

    # Detect existing install
    if [[ -d "$BASE_DIR/phpmyadmin" ]]; then
        success "phpMyAdmin is already installed"
        return 0
    fi

    warn "phpMyAdmin is not installed. Installing now..."

    # 1️⃣ Download
    run_step "Downloading phpMyAdmin" \
        retry 3 wget -qO "$PMA_TAR" "$PMA_URL" || return 1

    # 2️⃣ Extract directly into BASE_DIR
    run_step "Extracting phpMyAdmin" bash -c "
        set -e
        mkdir -p \"$BASE_DIR\"
        tar xzf \"$PMA_TAR\" -C \"$BASE_DIR\"
    " || return 1

    # 3️⃣ Detect extracted folder
    local EXTRACTED_DIR
    EXTRACTED_DIR=$(find "$BASE_DIR" -maxdepth 1 -type d -name "phpMyAdmin-*" | head -n 1)

    if [[ -z "$EXTRACTED_DIR" ]]; then
        error "Extraction failed: phpMyAdmin folder not found"
        return 1
    fi

    # 4️⃣ Create stable symlink
    run_step "Moving files to phpmyadmin" \
        mv "$EXTRACTED_DIR/*" "$BASE_DIR/phpmyadmin" || return 1

    local PMA_DIR="$BASE_DIR/phpmyadmin"

    # # 5️⃣ Create temp directory
    # run_step "Creating temp directory" bash -c "
    #     mkdir -p \"$TMP_DIR\"
    #     chown -R www-data:www-data \"$TMP_DIR\"
    #     chmod 700 \"$TMP_DIR\"
    # " || return 1

    # 6️⃣ Create config file
    run_step "Configuring phpMyAdmin" bash -c "
        cp \"$PMA_DIR/config.sample.inc.php\" \"$PMA_DIR/config.inc.php\"
    " || return 1

    # 7️⃣ Permissions
    run_step "Setting permissions" bash -c "
        chown -R www-data:www-data \"$BASE_DIR\"
        chmod -R 755 \"$BASE_DIR\"
    " || return 1

    success "phpMyAdmin installed successfully"
}