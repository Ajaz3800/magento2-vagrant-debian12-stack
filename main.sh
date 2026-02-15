#!/bin/bash

# Load libraries

source ./lib/colors.sh
source ./lib/logger.sh
source ./lib/utils.sh

# Credentials management
source ./lib/credentials.sh

# package installation functions
source ./lib/MySQL.sh
source ./lib/nginx.sh



main() {

set -euo pipefail

trap 'error "Script failed at line ${LINENO}"' ERR

require_root
check_network

info "Starting installation process..."

check_command wget
check_command curl

success "All dependencies are available"

info "Updating system packages..."

retry 3 apt-get update

success "System updated successfully"

setup_credentials

install_mysql

install_nginx

# ✅ Show summary
    echo ""
    info "Credentials file location:"
    echo "👉 $cred_file"
    echo ""

    info "Saved credentials:"
    echo "--------------------------------"
    echo "Database Name : $MYSQL_DB_NAME"
    echo "Username      : $MYSQL_DB_USER"
    echo "User Password : $MYSQL_DB_PASS"
    echo "MySQL Root PW : $MYSQL_ROOT_PASS"
    echo "--------------------------------"

info "Script completed successfully"

}

main "$@"