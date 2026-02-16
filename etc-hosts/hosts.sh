#!/bin/bash

update_hosts_file() {

    local IP="127.0.0.1"
    local HOSTS_FILE="/etc/hosts"

    warn "⚠ Updating /etc/hosts for $PMA_URL..."

    # Root check
    if [[ $EUID -ne 0 ]]; then
        error "✖ This step requires root privileges"
        return 1
    fi

    # Backup hosts file
    cp "$HOSTS_FILE" "${HOSTS_FILE}.bak"

    # Remove existing entry (if any)
    sed -i "/[[:space:]]$PMA_URL$/d" "$HOSTS_FILE"

    # Add new entry
    echo "$IP    $PMA_URL" >> "$HOSTS_FILE"

    success "✔ /etc/hosts updated: $PMA_URL → $IP"

    warn "⚠ Updating /etc/hosts for $BASE_URL..."

    # Root check
    if [[ $EUID -ne 0 ]]; then
        error "✖ This step requires root privileges"
        return 1
    fi

    # Backup hosts file
    cp "$HOSTS_FILE" "${HOSTS_FILE}.bak"

    # Remove existing entry (if any)
    sed -i "/[[:space:]]$BASE_URL$/d" "$HOSTS_FILE"

    # Add new entry
    echo "$IP    $BASE_URL" >> "$HOSTS_FILE"

    success "✔ /etc/hosts updated: $BASE_URL → $IP"
}