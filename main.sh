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

#install_nginx

#install_php

install_elasticsearch

install_redis

# 8️⃣ Test Elasticsearch
    echo ""
    info "Checking Elasticsearch status..."
    if curl -s -X GET "http://$NETWORK_HOST:$HTTP_PORT" | grep -q "cluster_name"; then
        printf "${GREEN}✔ Elasticsearch is running!${RESET}\n"
    else
        printf "${RED}✖ Elasticsearch is not responding!${RESET}\n"
    fi

# ✅ Check if Redis is running
    run_step "Checking Redis service status" bash -c "
        if systemctl is-active --quiet redis-server; then
            exit 0
        else
            echo 'Redis service is not running!' >&2
            exit 1
        fi
    "

    # Optional: test Redis CLI
    if redis-cli ping >/dev/null 2>&1; then
        success "Redis is running and responding to commands"
    else
        error "Redis is installed but not responding!"
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

info "Script completed successfully"

}

main "$@"