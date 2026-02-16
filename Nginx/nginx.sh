#!/bin/bash

install_nginx() {

    # Install nginx only if missing
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


    # Copy phpMyAdmin config (ALWAYS run)
    local src_config="./Nginx/config/phpmyadmin.conf.sample"
    local dest_config="/etc/nginx/sites-available/phpmyadmin.conf"
    local enabled_config="/etc/nginx/sites-enabled/phpmyadmin.conf"

    if [[ ! -f "$src_config" ]]; then
        error "phpMyAdmin config not found at $src_config"
        return 1
    fi

    run_step "Copying phpMyAdmin Nginx config" \
        cp "$src_config" "$dest_config" || return 1

    # Update server_name
    run_step "Updating domain in config" \
        sed -i "s|server_name .*;|server_name ${PMA_URL};|g" "$dest_config" || return 1


    # Enable site (symlink)
    if [[ ! -L "$enabled_config" ]]; then
        run_step "Enabling phpMyAdmin site" \
            ln -s "$dest_config" "$enabled_config" || return 1
    else
        success "phpMyAdmin site already enabled"
    fi


    # Copy Magento 2 config
    local magento_sample="./Nginx/config/magento2.conf.sample"
    local magento_dest="/etc/nginx/sites-available/magento2.conf"
    local magento_enabled="/etc/nginx/sites-enabled/magento2.conf"

    if [[ ! -f "$magento_sample" ]]; then
        error "Magento sample config not found at $magento_sample"
        return 1
    fi

    run_step "Copying Magento Nginx config" \
        cp "$magento_sample" "$magento_dest" || return 1
    

    # Update PHP-FPM socket
    run_step "Updating PHP-FPM version in config" \
        sed -i "s|php[0-9.]*-fpm.sock|php${PHP_VER}-fpm.sock|g" "$magento_dest" || return 1

    # Update server_name
    run_step "Updating domain in config" \
        sed -i "s|server_name .*;|server_name ${BASE_URL};|g" "$magento_dest" || return 1

    # Enable Magento site
    if [[ ! -L "$magento_enabled" ]]; then
        run_step "Enabling Magento site" \
            ln -s "$magento_dest" "$magento_enabled" || return 1
    else
        success "Magento site already enabled"
    fi


    # Test config
    if ! run_step "Testing Nginx configuration" nginx -t; then
        error "Nginx configuration test failed"
        return 1
    fi



    # Reload nginx
    run_step "Reloading Nginx" systemctl reload nginx || return 1

    success "phpMyAdmin Nginx configuration applied successfully"
}

