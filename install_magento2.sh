#!/bin/bash

# Load libraries
source ./lib/colors.sh
source ./lib/logger.sh
source ./lib/utils.sh

# Credentials management
source ./Credentials/credentials.sh

# package installation functions
source ./MySQL/MySQL.sh
source ./Nginx/nginx.sh
source ./php/php.sh
source ./Elasticsearch/elasticsearch.sh
source ./Redis/redis.sh
source ./phpmyadmin/phpmyadmin.sh
source ./Composer/composer.sh
source ./Magento2/magento2.sh
source ./Varnish/varnish.sh

# System config file
source ./etc-hosts/hosts.sh
source ./self_signed_ssl/self_signed_ssl.sh


main() {

set -euo pipefail

trap 'error "Script failed at line ${LINENO}"' ERR

init_steps 7

require_root
check_network

#info "Starting installation process..."

check_command wget
check_command curl

#success "All dependencies are available"

#info "Updating system packages..."

setup_credentials

run_step "Updating system packages" retry 3 apt-get update

success "✔ System updated successfully"

install_mysql

install_php

install_phpmyadmin

install_elasticsearch

install_redis

install_composer

install_magento2

update_hosts_file

install_nginx

generate_self_signed_ssl

setup_varnish_magento


# 8️⃣ Test Elasticsearch
    echo ""
    info "Checking Elasticsearch status..."
    if curl -s -X GET "http://$NETWORK_HOST:$HTTP_PORT" | grep -q "cluster_name"; then
        success "✔ Elasticsearch is running!"
    else
        error "✖ Elasticsearch is not responding!"
    fi

# ✅ Check if Redis is running
    if systemctl is-active --quiet redis-server; then
        success "✔ Redis service is running!"
    else
        error "✖ Redis service is not running!"
    fi

    # Optional: test Redis CLI
    if redis-cli ping >/dev/null 2>&1; then
        success "✔ Redis is running and responding to commands"
    else
        error "✖ Redis is installed but not responding!"
    fi

echo ""
success "✔ Installation completed successfully!"

# ✅ Show summary
    echo ""
    info "Credentials file location:"
    echo "👉 $cred_file"
    echo ""

    info "Saved MySQL credentials:"
    echo "--------------------------------"
    echo "Database Name : $MYSQL_DB_NAME"
    echo "Username      : $MYSQL_DB_USER"
    echo "User Password : $MYSQL_DB_PASS"
    echo "MySQL Root PW : $MYSQL_ROOT_PASS"
    echo "--------------------------------"

# 6️⃣ Test phpMyAdmin



local SERVER_IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Check nginx service first
if systemctl is-active --quiet nginx; then

    # Test phpMyAdmin endpoint (follow redirects, ignore SSL for self-signed)
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -L -k "https://$PMA_URL")

    if [ "$HTTP_STATUS" -eq 200 ]; then

        success "✔ phpMyAdmin is running!"
        echo "👉 Access phpMyAdmin in your browser:"
        echo ""
        echo "   http://$PMA_URL"
        echo "   https://$PMA_URL"
        echo ""
        echo "${CYAN}Tip:${RESET} If this is a VPS/server, use the public IP."
        echo ""

    else
        error "✖ phpMyAdmin endpoint is not responding!"
        warn "⚠ Check nginx config or PHP-FPM status."
        echo "   Last HTTP status code: $HTTP_STATUS"
    fi

else
    error "✖ Nginx service is not running!"
fi


if systemctl is-active --quiet nginx; then

    # Test Magento endpoint (follow redirects, ignore SSL for self-signed)
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -L -k "https://$BASE_URL")

    if [ "$HTTP_STATUS" -eq 200 ]; then

        success "✔ Varnish is running and caching Magento pages!"
        echo "👉 Access Magento in your browser:"
        echo ""
        echo "   http://$BASE_URL"
        echo "   https://$BASE_URL"
        echo ""
        echo "${CYAN}Tip:${RESET} If this is a VPS/server, use the public IP or Domain."
        echo ""

    else
        error "Varnish is not responding properly! HTTP status: $HTTP_STATUS"
        warn "⚠ Check Nginx, Varnish, and PHP-FPM status."
    fi

else
    error "✖ Nginx service is not running!"
fi


info "Script completed successfully"

}

main "$@"