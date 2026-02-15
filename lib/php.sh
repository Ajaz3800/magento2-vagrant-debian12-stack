#!/bin/bash

install_php() {

    # Check if PHP of that version is already installed
    if command -v php >/dev/null 2>&1 && php -v | grep -q "PHP $PHP_VER"; then
        success "PHP $PHP_VER is already installed"
        return 0
    fi

    warn "Installing PHP $PHP_VER..."

    # Update repo
    retry 3 apt-get update || return 1

    # Install PHP + common extensions
    # You can add more extensions as per your needs
    local extensions=(php${PHP_VER} php-fpm${PHP_VER} php${PHP_VER}-cli php${PHP_VER}-common php${PHP_VER}-mysql php${PHP_VER}-curl php${PHP_VER}-gd php${PHP_VER}-mbstring php${PHP_VER}-xml php${PHP_VER}-bcmath php${PHP_VER}-intl php${PHP_VER}-soap php${PHP_VER}-zip php${PHP_VER}-gd php${PHP_VER}-xmlrpc php${PHP_VER}-gmp)

    if retry 3 apt-get install -y "${extensions[@]}"; then
        phpenmod mbstring
        success "PHP $PHP_VER and extensions installed successfully"
    else
        error "Failed to install PHP $PHP_VER"
        return 1
    fi
}