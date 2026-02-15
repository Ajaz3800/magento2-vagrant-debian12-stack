#!/bin/bash

install_composer() {
    if command composer &> /dev/null; then
        success "Composer is already installed"
        return 0
    fi

    warn "Composer is not installed. I'm going to install it now."

    if run_step "Installing Composer" bash -c "
        set -e
        curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php 
        php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
        rm -f /tmp/composer-setup.php" 
    then
        success "Composer installed successfully"
    else
        error "Failed to install Composer"
        return 1
    fi
}