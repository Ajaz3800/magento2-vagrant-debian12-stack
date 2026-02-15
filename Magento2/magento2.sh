#!/bin/bash

install_magento2() {
    local MAGENTO_DIR="/var/www/html/magento2"

    if [[ -d "$MAGENTO_DIR" ]]; then
        success "Magento 2 is already installed"
        return 0
    fi

    warn "Magento 2 is not installed. Installing now..."

    # Download Magento 2 (using Composer or direct download)
    # For simplicity, we'll use Composer here

    if ! run_step "Installing Magento 2 via Composer" \
        composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=$MAG_VER "$MAGENTO_DIR"; then
        success "Magento 2 installed successfully"
        return 0
    else    
        error "Failed to install Magento 2"    
        return 1
    fi

    success "Magento 2 installed successfully at $MAGENTO_DIR"
}