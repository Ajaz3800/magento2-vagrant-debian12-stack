#!/bin/bash

VARNISH_VCL="/etc/varnish/magento.vcl"
MAGENTO_DEFAULT_CONF="/etc/nginx/sites-enabled/magento2-back.conf"

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

    # Configure Magento to use Varnish
    warn "Configuring Magento to use Varnish..."

    cd "$MAGENTO_DIR" || return 1

    if php bin/magento config:set system/full_page_cache/caching_application 2; then
        success "✔ Magento set to use Varnish"
    else
        error "✖ Failed to configure Magento cache"
        return 1
    fi

    if php bin/magento cache:flush; then
        success "✔ Magento cache flushed"
    else
        warn "⚠ Cache flush failed (continuing...)"
    fi


    # Generate Magento VCL safely
    warn "Generating Magento Varnish VCL..."

    if php bin/magento varnish:vcl:generate | sudo tee "$VARNISH_VCL" >/dev/null; then
        success "✔ VCL generated at $VARNISH_VCL"
    else
        error "✖ Failed to generate VCL"
        return 1
    fi

    # Restart Varnish
    warn "Restarting Varnish..."

    if sudo systemctl restart varnish; then
        success "✔ Varnish restarted"
    else
        error "✖ Failed to restart Varnish"
        return 1
    fi

    success "Varnish + Magento 2 setup complete!"
}