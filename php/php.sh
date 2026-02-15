#!/bin/bash

install_php() {

    # Check if PHP of that version is already installed
    if command -v php >/dev/null 2>&1 && php -v | grep -q "PHP $PHP_VER"; then
        success "PHP $PHP_VER is already installed"
        return 0
    fi

    warn "Installing PHP $PHP_VER..."

    # Update repo
    run_step "Adding PHP repository" retry 3 apt-get install -y lsb-release apt-transport-https ca-certificates wget gnupg || return 1
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg > /dev/null 2>&1
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list || return 1
    run_step "Updating APT cache" retry 3 apt-get update || return 1

    # Install PHP + common extensions
    # You can add more extensions as per your needs
    local extensions=(php${PHP_VER} php${PHP_VER}-fpm php${PHP_VER}-cli php${PHP_VER}-common php${PHP_VER}-mysql php${PHP_VER}-curl php${PHP_VER}-gd php${PHP_VER}-mbstring php${PHP_VER}-xml php${PHP_VER}-bcmath php${PHP_VER}-intl php${PHP_VER}-soap php${PHP_VER}-zip php${PHP_VER}-gd php${PHP_VER}-xmlrpc php${PHP_VER}-gmp)

    if run_step "Installing PHP $PHP_VER and extensions" retry 3 apt-get install -y "${extensions[@]}"; then
        phpenmod mbstring
        success "PHP $PHP_VER and extensions installed successfully"
    else
        error "Failed to install PHP $PHP_VER"
        return 1
    fi
}