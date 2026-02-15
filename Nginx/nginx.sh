#!/bin/bash

install_nginx() {

    # 1️⃣ Install nginx only if missing
    if ! dpkg -l nginx | grep -q "^ii"; then
        warn "Nginx is not installed. Installing now..."

        if ! run_step "Installing Nginx" retry 3 apt-get install -y nginx; then
            error "Failed to install Nginx"
            return 1
        fi

        success "Nginx installed successfully"
    else
        success "Nginx is already installed"
    fi


    # 2️⃣ Copy phpMyAdmin config (ALWAYS run)
    local src_config="./Nginx/config/phpmyadmin.conf"
    local dest_config="/etc/nginx/sites-available/phpmyadmin.conf"
    local enabled_config="/etc/nginx/sites-enabled/phpmyadmin.conf"

    if [[ ! -f "$src_config" ]]; then
        error "phpMyAdmin config not found at $src_config"
        return 1
    fi

    run_step "Copying phpMyAdmin Nginx config" \
        cp "$src_config" "$dest_config" || return 1


    # 3️⃣ Enable site (symlink)
    if [[ ! -L "$enabled_config" ]]; then
        run_step "Enabling phpMyAdmin site" \
            ln -s "$dest_config" "$enabled_config" || return 1
    else
        success "phpMyAdmin site already enabled"
    fi


    # 4️⃣ Test config
    if ! run_step "Testing Nginx configuration" nginx -t; then
        error "Nginx configuration test failed"
        return 1
    fi


    # 5️⃣ Reload nginx
    run_step "Reloading Nginx" systemctl reload nginx || return 1

    success "phpMyAdmin Nginx configuration applied successfully"
}

