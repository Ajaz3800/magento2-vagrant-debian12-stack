#!/bin/bash

install_elasticsearch() {
    if dpkg -l elasticsearch | grep -q "^ii"; then
        success "✔ Elasticsearch is already installed"
        return 0
    fi

    warn "⚠ Elasticsearch is not installed. I'm going to install it now."

    # ---------- Install & Configure Elasticsearch ----------
if run_step "Installing OpenJDK 17" retry 3 apt-get install -y openjdk-17-jdk &&
   wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg &&
   echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/$VER_ES.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-$VER_ES.x.list &&
   run_step "Updating APT cache" retry 3 apt-get update &&
   run_step "Installing Elasticsearch" retry 3 apt-get install -y elasticsearch
then
    success "✔ Elasticsearch installed successfully"

    # Enable & start service
    run_step "Configuring systemd service" bash -c "
        sudo systemctl daemon-reload &&
        sudo systemctl enable elasticsearch.service &&
    "

    # Interactive configuration
    local es_config="/etc/elasticsearch/elasticsearch.yml"
    cp "$es_config" "${es_config}.bak"

    # Remove existing config lines if present
    sudo sed -i "/^node.name:/d" "$es_config"
    sudo sed -i "/^cluster.name:/d" "$es_config"
    sudo sed -i "/^network.host:/d" "$es_config"
    sudo sed -i "/^http.port:/d" "$es_config"
    sudo sed -i "/^xpack.security.enabled/d" "$es_config"
    sudo sed -i "/^xpack.security.enrollment.enabled:/d" "$es_config"

    # Append user settings
    {
        echo "node.name: \"$NODE_NAME\""
        echo "cluster.name: $CLUSTER_NAME"
        echo "network.host: $NETWORK_HOST"
        echo "http.port: $HTTP_PORT"
        echo "xpack.security.enabled: false"
        echo "xpack.security.enrollment.enabled: false"
    } | sudo tee -a "$es_config" >/dev/null

    # Configure JVM heap size
    local jvm_opts="/etc/elasticsearch/jvm.options"
    cp "$jvm_opts" "${jvm_opts}.bak"

    # Update or uncomment -Xms and -Xmx lines
    sudo sed -i "s|^-Xms.*|-Xms$HEAP_MIN|g" "$jvm_opts"
    sudo sed -i "s|^-Xmx.*|-Xmx$HEAP_MAX|g" "$jvm_opts"

    # Add lines if missing
    grep -q "^-Xms" "$jvm_opts" || echo "-Xms$HEAP_MIN" | sudo tee -a "$jvm_opts"
    grep -q "^-Xmx" "$jvm_opts" || echo "-Xmx$HEAP_MAX" | sudo tee -a "$jvm_opts"

    success "✔ JVM heap size configured: -Xms$HEAP_MIN -Xmx$HEAP_MAX"

    # Reload & restart Elasticsearch
    run_step "Reloading systemd & restarting Elasticsearch" bash -c "
        sudo systemctl daemon-reload &&
        sudo systemctl restart elasticsearch.service
        sudo systemctl start elasticsearch.service
    "

    # Verify Elasticsearch is running
    if curl -s -X GET "http://localhost:$HTTP_PORT" >/dev/null; then
        success "✔ Elasticsearch is running on port $HTTP_PORT"
    else
        error "✖ Elasticsearch failed to start"
        exit 1
    fi

else
    error "Elasticsearch installation or initial setup failed"
    exit 1
fi

}