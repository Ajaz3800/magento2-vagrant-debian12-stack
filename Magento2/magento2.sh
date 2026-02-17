#!/bin/bash

install_magento2() {

    MAGENTO_DIR="/var/www/html/magento2"

    # if [[ -f "$MAGENTO_DIR/app/etc/env.php" ]] && \
    #    php "$MAGENTO_DIR/bin/magento" --version >/dev/null 2>&1; then
    #    success "Magento 2 is already installed and working"
    #    return
    # fi

    if [[ -d "$MAGENTO_DIR" ]]; then

    # If Magento is valid → skip install
    if [[ -f "$MAGENTO_DIR/app/etc/env.php" ]] && \
       php "$MAGENTO_DIR/bin/magento" --version >/dev/null 2>&1; then

        success "✔ Magento already installed and working. Skipping install."
        return 0
    fi

    # Otherwise broken install → remove
    warn "⚠ Found incomplete Magento directory. Cleaning..."

    rm -rf "$MAGENTO_DIR" || {
        error "✖ Failed to remove broken Magento directory"
        return 1
    }
    fi

    warn "⚠ Magento 2 is not installed. Installing now..."

    # --- Configure composer auth ---

    run_step "Configuring Composer authentication" bash -c "
        composer config --global http-basic.repo.magento.com \
        \"$MAGENTO_PUBLIC\" \"$MAGENTO_PRIVATE\"
    " || return 1

    # --- Install Magento ---

    run_step "Installing unzip" apt install -y unzip || return 1

    # Create directory if it does not exist
    if [[ ! -d "$MAGENTO_DIR" ]]; then
        sudo mkdir -p "$MAGENTO_DIR" || {
            error "✖ Failed to create Magento directory"
            return 1
        }
        success "✔ Magento directory created"
    else
        warn "⚠ Magento directory already exists"
    fi

    # Detect real user (works with or without sudo)

    # Set ownership correctly

    sudo chown -R "$REAL_USER":www-data "$MAGENTO_DIR" || {
    error "✖ Failed to set ownership"
    return 1
    }


    # Set permissions
    sudo chmod -R 775 "$MAGENTO_DIR" || {
        error "✖ Failed to set permissions"
        return 1
    }

    success "✔ Magento directory is ready"



    if run_step "Installing Magento 2 via Composer" bash -c "
        sudo -u "$REAL_USER" composer create-project \
        --repository-url=https://repo.magento.com/ \
        magento/project-community-edition=$MAG_VER \
        \"$MAGENTO_DIR\"
    "
    then
        success "✔ Magento 2 installed successfully at $MAGENTO_DIR"
    else
        error "✖ Failed to install Magento 2"
        return 1
    fi

    # -----------Permissions------------

    run_step "Setting Magento permissions" bash -c "
        cd \"$MAGENTO_DIR\" &&
        sudo -u "$REAL_USER" find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + &&
        find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + &&
        chown -R $REAL_USER:www-data . &&
        chmod -R 775 bin/magento
    " || return 1

    # ----------Magento setup install

    if run_step "Running Magento setup install" sudo -u "$REAL_USER" bash -c '
        cd "'"$MAGENTO_DIR"'" || exit 1
        php bin/magento setup:install \
        --base-url=http://'"$BASE_URL"' \
        --db-host=localhost \
        --db-name='"$MYSQL_DB_NAME"' \
        --db-user='"$MYSQL_DB_USER"' \
        --db-password='"$MYSQL_DB_PASS"' \
        --admin-firstname=Admin \
        --admin-lastname=Admin \
        --admin-email='"$ADMIN_EMAIL"' \
        --admin-user='"$ADMIN_USER"' \
        --admin-password='"$ADMIN_PASS"' \
        --language=en_US \
        --currency=USD \
        --timezone=America/Chicago \
        --backend-frontname=admin \
        --search-engine=elasticsearch'"$VER_ES"' \
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
        '; then
        success "✔ Magento setup completed successfully"
    else
        error "✖ Magento setup failed"
        return 1
    fi


        # ---------- Magento post-install optimization ----------

    if run_step "Running Magento post-install tasks" bash -c "
        cd \"$MAGENTO_DIR\" &&
        sudo -u "$REAL_USER" php bin/magento indexer:reindex &&
        php bin/magento setup:upgrade &&
        php bin/magento setup:static-content:deploy -f &&
        php bin/magento cache:flush &&
        php bin/magento module:disable Magento_TwoFactorAuth Magento_AdminAdobeImsTwoFactorAuth
    "
    then
        success "✔ Magento post-install tasks completed"
    else
        error "✖ Magento post-install tasks failed"
        return 1
    fi


    success "✔ Magento 2 installed successfully!"
}
