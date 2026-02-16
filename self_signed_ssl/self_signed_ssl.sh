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
    local MAGENTO_CONF="/etc/nginx/sites-available/magento2-front.conf"
    local MAGENTO_ENABLED="/etc/nginx/sites-enabled/magento2-front.conf"

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

    # Update nginx config file
    warn "Updating nginx config..."

    cat >> "$MAGENTO_CONF" <<EOF
server {
    listen 443 ssl http2;
    server_name $BASE_URL;

    ssl_certificate $CERT;
    ssl_certificate_key $KEY;

    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;

    location / {
          proxy_pass http://127.0.0.1:6081;  # Varnish
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto https;
    }
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

    sudo -u "$REAL_USER" php bin/magento config:set web/unsecure/base_url https://$BASE_URL/
    sudo -u "$REAL_USER" php bin/magento config:set web/secure/base_url https://$BASE_URL/
    sudo -u "$REAL_USER" php bin/magento config:set web/secure/use_in_frontend 1
    sudo -u "$REAL_USER" php bin/magento config:set web/secure/use_in_adminhtml 1
    sudo -u "$REAL_USER" php bin/magento cache:flush

    success "Magento base URLs updated and cache flushed"

    success "SSL setup completed successfully!"
}