#!/bin/bash

install_redis() {
    if dpkg -l redis-server | grep -q "^ii"; then
        success "Redis is already installed"
        return 0
    fi

    warn "Redis is not installed. I'm going to install it now."

    # Install prerequisites, Redis, and start service
    if run_step "Installing Redis dependencies" retry 3 apt-get install -y lsb-release curl gpg &&
    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg &&
    sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg &&
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list &&
    run_step "Updating APT cache" retry 3 apt-get update &&
    run_step "Installing Redis server" retry 3 apt-get install -y redis &&
    run_step "Starting Redis service" bash -c "
        sudo systemctl daemon-reload &&
        sudo systemctl enable redis-server.service &&
        sudo systemctl start redis-server.service
    "
    then
        success "Redis installed and running successfully"
    else
        error "Redis installation or service start failed"
        exit 1
    fi
}   