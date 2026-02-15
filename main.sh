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

run_step "Updating system packages" retry 3 apt-get update

success "System updated successfully"

setup_credentials

#install_mysql

install_phpmyadmin

#install_php

#install_elasticsearch

#install_redis

install_nginx

# 8️⃣ Test Elasticsearch
    echo ""
    info "Checking Elasticsearch status..."
    if curl -s -X GET "http://$NETWORK_HOST:$HTTP_PORT" | grep -q "cluster_name"; then
        printf "${GREEN}✔ Elasticsearch is running!${RESET}\n"
    else
        printf "${RED}✖ Elasticsearch is not responding!${RESET}\n"
    fi

# ✅ Check if Redis is running
        if systemctl is-active --quiet redis-server; then
            exit 0
        else
            print "${RED}✖ Redis service is not running!${RESET}\n" >&2
            exit 1
        fi

    # Optional: test Redis CLI
    if redis-cli ping >/dev/null 2>&1; then
        printf "${GREEN}✔ Redis is running and responding to commands${RESET}\n"
    else
        printf "${RED}✖ Redis is installed but not responding!${RESET}\n"
        return 1
    fi

echo ""
printf "${GREEN}✔ Installation completed successfully!${RESET}\n"

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

    # Test phpMyAdmin endpoint
    if curl -s -o /dev/null -w "%{http_code}" http://localhost/phpmyadmin | grep -q "200"; then

        printf "${GREEN}✔ phpMyAdmin is running!${RESET}\n"
        echo "👉 Access phpMyAdmin in your browser:"
        echo ""
        echo "   http://localhost/phpmyadmin"
        echo "   http://${SERVER_IP}/phpmyadmin"
        echo ""
        echo "${CYAN}Tip:${RESET} If this is a VPS/server, use the public IP."
        echo ""

    else
        printf "${RED}✖ phpMyAdmin endpoint is not responding!${RESET}\n"
        printf "${YELLOW}⚠ Check nginx config or PHP-FPM status.${RESET}\n"
    fi

else
    printf "${RED}✖ Nginx service is not running!${RESET}\n"
fi



info "Script completed successfully"

}

main "$@"