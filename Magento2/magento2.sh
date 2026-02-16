#!/bin/bash

install_magento2() {

    local MAGENTO_DIR="/var/www/html/magento2"

    if [[ -f "$MAGENTO_DIR/app/etc/env.php" ]] && \
       php "$MAGENTO_DIR/bin/magento" --version >/dev/null 2>&1; then
       success "Magento 2 is already installed and working"
       return
    fi

    warn "Magento 2 is not installed. Installing now..."

    # --- Ask Magento credentials ---

    echo ""
    warn "Magento Marketplace authentication required"

    read -rp "Enter Magento Public Key: " MAGENTO_PUBLIC
    read -rsp "Enter Magento Private Key: " MAGENTO_PRIVATE
    echo ""

    # --- Configure composer auth ---

    run_step "Configuring Composer authentication" bash -c "
        composer config --global http-basic.repo.magento.com \
        \"$MAGENTO_PUBLIC\" \"$MAGENTO_PRIVATE\"
    " || return 1

    # --- Install Magento ---

    run_step "Installing unzip" apt install -y unzip || return 1

    if run_step "Installing Magento 2 via Composer" bash -c "
        composer create-project \
        --repository-url=https://repo.magento.com/ \
        magento/project-community-edition=$MAG_VER \
        \"$MAGENTO_DIR\"
    "
    then
        success "Magento 2 installed successfully at $MAGENTO_DIR"
    else
        error "Failed to install Magento 2"
        return 1
    fi

    # -----------Permissions------------

    run_step "Setting Magento permissions" bash -c "
        cd \"$MAGENTO_DIR\" &&
        find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + &&
        find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + &&
        chown -R $USER:www-data . &&
        chmod -R 775 bin/magento
    " || return 1

    # ----------Magento setup install

    if ! run_step "Running Magento setup install" bash -c "
        cd \"$MAGENTO_DIR\" &&
        php bin/magento setup:install \
        --base-url=\"$BASE_URL\" \
        --db-host=localhost \
        --db-name=\"$MYSQL_DB_NAME\" \
        --db-user=\"$MYSQL_DB_USER\" \
        --db-password=\"$MYSQL_DB_PASS\" \
        --admin-firstname=Admin \
        --admin-lastname=Admin \
        --admin-email=\"$ADMIN_EMAIL\" \
        --admin-user=\"$ADMIN_USER\" \
        --admin-password=\"$ADMIN_PASS\" \
        --language=en_US \
        --currency=USD \
        --timezone=America/Chicago \
        --backend-frontname=admin \
        --search-engine=elasticsearch$VER_ES \
        --elasticsearch-host=127.0.0.1 \
        --elasticsearch-port=9200 \
        --cache-backend=redis \
        --cache-backend-redis-server=127.0.0.1 \
        --cache-backend-redis-db=0 \
        --page-cache=redis \
        --page-cache-redis-server=127.0.0.1 \
        --page-cache-redis-db=1 \
        --session-save=redis \
        --session-save-redis-host=127.0.0.1 \
        --session-save-redis-db=2
    "
    then
        success "Magento setup completed successfully"
    else
        error "Magento setup failed"
        return 1
    fi

    success "Magento 2 installed successfully!"
}
