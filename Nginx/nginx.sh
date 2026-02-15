#!/bin/bash

install_nginx() {
    if dpkg -l nginx | grep -q "^ii"; then
        success "Nginx is already installed"
        return 0
    fi

    warn "Nginx is not installed. I'm going to install it now."

    if  run_step "Installing Nginx" retry 3 apt-get install -y nginx; then
        success "Nginx installed successfully"
    else
        error "Failed to install Nginx"
        return 1
    fi

    # 2️⃣ Copy phpMyAdmin config
    local src_config="./config/phpmyadmin.conf"
    local dest_config="/etc/nginx/sites-available/phpmyadmin.conf"
    local enabled_config="/etc/nginx/sites-enabled/phpmyadmin.conf"

    if [[ ! -f "$src_config" ]]; then
        error "phpMyAdmin config not found at $src_config"
        return 1
    fi

    run_step "Copying phpMyAdmin Nginx config" cp "$src_config" "$dest_config" || return 1

    # 3️⃣ Enable site (symlink)
    if [[ ! -L "$enabled_config" ]]; then
        run_step "Enabling phpMyAdmin site" ln -s "$dest_config" "$enabled_config" || return 1
    fi

    # 4️⃣ Test Nginx config
    if ! run_step "Testing Nginx configuration" nginx -t; then
        error "Nginx configuration test failed"
        return 1
    fi

    # 5️⃣ Reload Nginx
    run_step "Reloading Nginx" systemctl reload nginx || return 1

    success "phpMyAdmin Nginx configuration applied successfully"
}
