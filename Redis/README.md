# Redis Setup Script for Magento (Debian 12)

This script installs and configures **Redis** for Magento on Debian 12. It installs Redis from the official repository, enables the service, and prepares it for Magento caching and session storage.

Redis improves Magento performance by providing fast in-memory caching.

---

## Features

* Installs Redis from official repository
* Enables and starts Redis service
* Prepares Redis for Magento caching
* Automatic dependency installation
* Safe to re-run (idempotent)

---

## 🚀 Full Magento Stack Installation (Recommended)

If you want to install the **complete Magento environment** (NGINX, PHP, MySQL, Redis, Varnish, Elasticsearch, etc.), clone the full stack repository and run the installer:

```bash
git clone https://github.com/Ajaz3800/magento2-vagrant-debian12-stack.git
cd magento2-vagrant-debian12-stack
sudo ./install_magento2.sh
```

This Redis script is included automatically in the full setup.

---

## Requirements

* Debian 12
* Root or sudo access
* Internet connection

---

## Run the Script

```bash
chmod +x redis.sh
sudo ./redis.sh
```

---

## Manual Installation (Without Script)

If you want to install Redis manually, follow these steps.

### 1. Install Dependencies

```bash
sudo apt-get install -y lsb-release curl gpg
```

---

### 2. Add Redis Repository

```bash
curl -fsSL https://packages.redis.io/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] \
https://packages.redis.io/deb $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/redis.list

sudo apt-get update
```

---

### 3. Install Redis

```bash
sudo apt-get install -y redis
```

---

### 4. Enable and Start Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

---

## Verification

Check Redis status:

```bash
redis-cli ping
```

You should see:

```
PONG
```

---

## Troubleshooting

### Redis not running

```bash
sudo systemctl status redis-server
sudo systemctl restart redis-server
```

---

### Port conflict

```bash
sudo ss -tulnp | grep 6379
```

---

## Notes

* Designed for Magento caching and sessions
* Improves Magento performance
* Safe to run multiple times

---