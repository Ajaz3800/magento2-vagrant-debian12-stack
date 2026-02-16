generate_self_signed_ssl() {

    local SSL_DIR="/etc/nginx/ssl"

    warn "Generating self-signed SSL certificate for $PMA_URL..."

    local CERT="$SSL_DIR/$PMA_URL.crt"
    local KEY="$SSL_DIR/$PMA_URL.key"
    local PMA_CONF="/etc/nginx/sites-available/phpmyadmin.conf"
    local PMA_ENABLED="/etc/nginx/sites-enabled/phpmyadmin.conf"

    mkdir -p "$SSL_DIR"

    run_step "Generating SSL certificate for phpMyAdmin" bash -c "
         openssl req -x509 -nodes -days 365 \
            -newkey rsa:2048 \
            -keyout "$KEY" \
            -out "$CERT" \
            -subj "/C=US/ST=State/L=City/O=Dev/CN=$PMA_URL"
    " || return 1

    if [[ $? -ne 0 ]]; then
        error "Failed to generate SSL certificate"
        return 1
    fi

    success "SSL certificate generated: $CERT"

    # 🔥 Update nginx config file
    warn "Updating nginx config..."

    cat > "$PMA_CONF" <<EOF
server {
    listen 443 ssl;
    server_name $PMA_URL;

    ssl_certificate $CERT;
    ssl_certificate_key $KEY;

    root /var/www/html/phpmyadmin;
    index index.php;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
    }
}
EOF

    # Enable site
    if [[ ! -L "$PMA_ENABLED" ]]; then
        ln -s "$PMA_CONF" "$PMA_ENABLED"
        success "phpMyAdmin site enabled"
    fi

    # ---------- Repeat for Magento 2 ----------

    warn "Generating self-signed SSL certificate for $BASE_URL..."

    local CERT="$SSL_DIR/$BASE_URL.crt"
    local KEY="$SSL_DIR/$BASE_URL.key"
    local MAGENTO_CONF="/etc/nginx/sites-available/magento2.conf"
    local MAGENTO_ENABLED="/etc/nginx/sites-enabled/magento2.conf"

    mkdir -p "$SSL_DIR"

    run_step "Generating SSL certificate for Magento 2" bash -c "
         openssl req -x509 -nodes -days 365 \
            -newkey rsa:2048 \
            -keyout "$KEY" \
            -out "$CERT" \
            -subj "/C=US/ST=State/L=City/O=Dev/CN=$BASE_URL"
    " || return 1

    if [[ $? -ne 0 ]]; then
        error "Failed to generate SSL certificate"
        return 1
    fi

    success "SSL certificate generated: $CERT"

    # 🔥 Update nginx config file
    warn "Updating nginx config..."

    cat > "$MAGENTO_CONF" <<EOF
upstream fastcgi_backend {
    server unix:/run/php/php$PHP_VER-fpm.sock;
}

# HTTP → HTTPS redirect ONLY
server {
    listen 80;
    server_name $BASE_URL;
    return 301 https://$host$request_uri;
}

# HTTPS Magento
server {
    listen 443 ssl http2;
    server_name $BASE_URL;

    ssl_certificate $CERT;
    ssl_certificate_key $KEY;

    set $MAGE_ROOT /var/www/html/magento2;
    set $MAGE_MODE production;

    include /var/www/html/magento2/nginx.conf.sample;

    # Optional security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
EOF

    # Enable site
    if [[ ! -L "$MAGENTO_ENABLED" ]]; then
        ln -s "$MAGENTO_CONF" "$MAGENTO_ENABLED"
        success "Magento 2 site enabled"
    fi

    # Reload nginx
    warn "Reloading nginx..."
    nginx -t && systemctl reload nginx

    # ✅ Update Magento base URLs to HTTPS
    warn "Updating Magento base URLs to HTTPS..."
    cd "$MAGENTO_DIR" || exit 1

    php bin/magento config:set web/unsecure/base_url https://$BASE_URL/
    php bin/magento config:set web/secure/base_url https://$BASE_URL/
    php bin/magento config:set web/secure/use_in_frontend 1
    php bin/magento config:set web/secure/use_in_adminhtml 1
    php bin/magento cache:flush

    success "Magento base URLs updated and cache flushed"

    success "SSL setup completed successfully!"
}