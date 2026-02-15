#!/bin/bash

install_elasticsearch() {
    if dpkg -l elasticsearch | grep -q "^ii"; then
        success "Elasticsearch is already installed"
        return 0
    fi

    warn "Elasticsearch is not installed. I'm going to install it now."

    if  run_step "Installing OpenJDK 17" retry 3 apt-get install -y openjdk-17-jdk; then
        wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/9.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-9.x.list
        run_step "Updating APT cache" retry 3 apt-get update || return 1
        run_step "Installing Elasticsearch" retry 3 apt-get install -y elasticsearch || return 1
        success "Elasticsearch installed successfully"
    else
        error "Failed to install Elasticsearch"
        return 1
    fi
    # 5️⃣ Enable & start service
    run_step "Configuring systemd service" bash -c "
        sudo systemctl daemon-reload &&
        sudo systemctl enable elasticsearch.service &&
        sudo systemctl start elasticsearch.service
    "
    # 6️⃣ Interactive configuration
    local es_config="/etc/elasticsearch/elasticsearch.yml"
    
    # Backup config before editing
    cp "$es_config" "${es_config}.bak"

    # Remove existing config lines if present
    sudo sed -i "/^node.name:/d" "$es_config"
    sudo sed -i "/^cluster.name:/d" "$es_config"
    sudo sed -i "/^network.host:/d" "$es_config"
    sudo sed -i "/^http.port:/d" "$es_config"

    # Append user settings
    {
        echo "node.name: \"$NODE_NAME\""
        echo "cluster.name: $CLUSTER_NAME"
        echo "network.host: $NETWORK_HOST"
        echo "http.port: $HTTP_PORT"
    } | sudo tee -a "$es_config" >/dev/null

    # 7️⃣ Configure JVM heap size
    local jvm_opts="/etc/elasticsearch/jvm.options"
    cp "$jvm_opts" "${jvm_opts}.bak"

     # Update or uncomment -Xms and -Xmx lines
    sudo sed -i "s|^-Xms.*|-Xms$HEAP_MIN|g" "$jvm_opts"
    sudo sed -i "s|^-Xmx.*|-Xmx$HEAP_MAX|g" "$jvm_opts"

    # Add lines if they were missing
    grep -q "^-Xms" "$jvm_opts" || echo "-Xms$HEAP_MIN" | sudo tee -a "$jvm_opts"
    grep -q "^-Xmx" "$jvm_opts" || echo "-Xmx$HEAP_MAX" | sudo tee -a "$jvm_opts"

    success "JVM heap size configured: -Xms$HEAP_MIN -Xmx$HEAP_MAX"

    # 7️⃣ Reload & restart Elasticsearch
    run_step "Reloading systemd & restarting Elasticsearch" bash -c "
        sudo systemctl daemon-reload &&
        sudo systemctl restart elasticsearch.service
    "

    # 8️⃣ Test Elasticsearch
    echo ""
    info "Checking Elasticsearch status..."
    if curl -s -X GET "http://$NETWORK_HOST:$HTTP_PORT" | grep -q "cluster_name"; then
        printf "${GREEN}✔ Elasticsearch is running!${RESET}\n"
    else
        printf "${RED}✖ Elasticsearch is not responding!${RESET}\n"
    fi

}