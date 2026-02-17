# Elasticsearch Setup Script for Magento (Debian 12)

This script installs and configures **Elasticsearch** for Magento on Debian 12. It installs OpenJDK, adds the official Elasticsearch repository, configures Elasticsearch settings, and prepares it for Magento compatibility.

Elasticsearch is required by Magento for advanced product search and indexing.

---

## Features

* Installs OpenJDK 17 automatically
* Installs selected Elasticsearch version
* Configures single-node cluster
* Sets JVM heap size
* Disables security for local Magento development
* Enables and starts Elasticsearch service
* Safe to re-run (idempotent)

---

## 🚀 Full Magento Stack Installation (Recommended)

If you want to install the **complete Magento environment** (NGINX, PHP, MySQL, Redis, Varnish, Elasticsearch, etc.), clone the full stack repository and run the installer:

```bash
git clone https://github.com/Ajaz3800/magento2-vagrant-debian12-stack.git
cd magento2-vagrant-debian12-stack
sudo ./install_magento2.sh
```

This Elasticsearch script is included automatically in the full setup.

---

## Requirements

* Debian 12
* Root or sudo access
* Internet connection
* Minimum 2GB RAM recommended

---

## Environment Variables

Set configuration variables before running:

```bash
export VER_ES="8"
export NODE_NAME="magento-node"
export CLUSTER_NAME="magento-cluster"
export NETWORK_HOST="127.0.0.1"
export HTTP_PORT="9200"
export HEAP_MIN="1g"
export HEAP_MAX="1g"
```

You can adjust values based on your system resources.

---

## Run the Script

```bash
chmod +x elasticsearch.sh
sudo ./elasticsearch.sh
```

---

## Manual Installation (Without Script)

If you want to install Elasticsearch manually, follow these steps.

### 1. Install Java

```bash
sudo apt-get install -y openjdk-17-jdk
```

---

### 2. Add Elasticsearch Repository

```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | \
sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] \
https://artifacts.elastic.co/packages/8.x/apt stable main" | \
sudo tee /etc/apt/sources.list.d/elastic-8.x.list

sudo apt-get update
```

---

### 3. Install Elasticsearch

```bash
sudo apt-get install -y elasticsearch
```

---

### 4. Basic Configuration

Edit configuration:

```bash
sudo nano /etc/elasticsearch/elasticsearch.yml
```

Add:

```
node.name: magento-node
cluster.name: magento-cluster
network.host: 127.0.0.1
http.port: 9200
discovery.type: single-node
xpack.security.enabled: false
```

---

### 5. Configure JVM Heap Size

```bash
sudo nano /etc/elasticsearch/jvm.options
```

Set:

```
-Xms1g
-Xmx1g
```

---

### 6. Enable and Start Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl restart elasticsearch
```

---

## Verification

Check Elasticsearch status:

```bash
curl http://localhost:9200
```

You should see JSON output confirming Elasticsearch is running.

---

## Troubleshooting

### Elasticsearch not starting

```bash
sudo systemctl status elasticsearch
sudo journalctl -u elasticsearch
```

---

### Port already in use

```bash
sudo ss -tulnp | grep 9200
```

Change port in configuration if needed.

---

## Notes

* Designed for Magento development environments
* Security is disabled for local setup
* Adjust heap size based on RAM
* Safe to run multiple times

---