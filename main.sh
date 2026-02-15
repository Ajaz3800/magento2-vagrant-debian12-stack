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

info "Script completed successfully"

}

main "$@"