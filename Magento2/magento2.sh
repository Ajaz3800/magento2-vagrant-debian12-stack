#!/bin/bash

install_magento2() {

    local MAGENTO_DIR="/var/www/html/magento2"

    if [[ -d "$MAGENTO_DIR" ]]; then
        success "Magento 2 is already installed"
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

    if run_step "Installing Magento 2 via Composer" bash -c "
        export COMPOSER_ALLOW_SUPERUSER=1
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
}
