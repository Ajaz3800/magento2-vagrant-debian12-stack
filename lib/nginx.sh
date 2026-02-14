#!/bin/bash

install_nginx() {
    if dpkg -l nginx | grep -q "^ii"; then
        success "Nginx is already installed"
        return 0
    fi

    warn "Nginx is not installed. I'm going to install it now."

    if retry 3 apt-get install -y nginx; then
        success "Nginx installed successfully"
    else
        error "Failed to install Nginx"
        return 1
    fi
}
