#!/bin/bash

VARNISH_VCL="/etc/varnish/magento.vcl"
MAGENTO_DEFAULT_CONF="/etc/nginx/sites-enabled/magento2.conf"

setup_varnish_magento() {

    # Check if Magento root exists
    if [ ! -d "$MAGENTO_DIR" ]; then
        error "✖ Magento root directory not found at $MAGENTO_DIR"
        return 1
    fi

    # Check if Varnish is installed
    if command -v varnishd &>/dev/null || [ -x /usr/sbin/varnishd ]; then
        success "✔ Varnish is already installed."
    else
        warn "⚠ Varnish not found. Installing..."
        run_step "Installing Varnish" retry 3 sudo apt-get update && sudo apt-get install varnish -y

        # Check again
        if command -v varnishd &>/dev/null || [ -x /usr/sbin/varnishd ]; then
            success "✔ Varnish installed."
        else
            error "✖ Varnish installation failed!"
            return 1
        fi
    fi


    # Generate Magento VCL safely
    warn "Generating Magento Varnish VCL..."
    if php "$MAGENTO_DIR/bin/magento" varnish:vcl:generate | sudo tee "$VARNISH_VCL" >/dev/null; then
        success "✔ Magento VCL generated at $VARNISH_VCL"
    else
        error "✖ Failed to generate Magento VCL. Check permissions."
        return 1
    fi

    # Configure Varnish to listen on port 80
    warn "Configuring Varnish to listen on port 80..."
    sed -i 's/^VARNISH_LISTEN_PORT=.*/VARNISH_LISTEN_PORT=80/' /etc/default/varnish 2>/dev/null || true
    sed -i 's/^VARNISH_STORAGE_SIZE=.*/VARNISH_STORAGE_SIZE=1G/' /etc/default/varnish 2>/dev/null || true

    # Configure Nginx to listen on port 8080
    if [ -f "$MAGENTO_DEFAULT_CONF" ]; then
        warn "Configuring Nginx to listen on 8080..."
        sed -i 's/listen 80;/listen 8080;/' "$MAGENTO_DEFAULT_CONF"
    else
        warn "⚠ Nginx Magento config not found at $MAGENTO_DEFAULT_CONF. Skipping port change."
    fi

    # Reload and restart services
    warn "Restarting Nginx and Varnish..."
    nginx -t && systemctl restart nginx
    systemctl restart varnish

    success "Varnish + Magento 2 setup complete!"
}