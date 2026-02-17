# Magento 2 Installation Script (Debian 12)

This script installs **Magento 2** automatically on Debian 12 using Composer. It handles authentication, downloads Magento, sets permissions, runs setup installation, and performs post-install optimization.

It is designed to work with the full Magento stack (NGINX, PHP, MySQL, Redis, Elasticsearch).

---

## Features

* Installs Magento 2 via Composer
* Cleans broken/incomplete installations
* Automatically configures Composer authentication
* Sets Magento file permissions
* Runs Magento setup install
* Configures Redis + Elasticsearch integration
* Performs post-install optimization
* Safe to re-run (idempotent)

---

## 🚀 Full Magento Stack Installation (Recommended)

To install the **complete Magento environment automatically**, run:

```bash
git clone https://github.com/Ajaz3800/magento2-vagrant-debian12-stack.git
cd magento2-vagrant-debian12-stack
sudo ./install_magento2.sh
```

This script is part of the full automated installer.

---

## Requirements

* Debian 12
* PHP + Composer installed
* MySQL running
* Redis running
* Elasticsearch running
* Root or sudo access
* Magento Marketplace API keys

---

## Environment Variables

Set required variables before running:

```bash
export MAG_VER="2.4.7"
export MAGENTO_PUBLIC="your_public_key"
export MAGENTO_PRIVATE="your_private_key"

export MYSQL_DB_NAME="magento_db"
export MYSQL_DB_USER="magento_user"
export MYSQL_DB_PASS="magento_password"

export ADMIN_EMAIL="admin@example.com"
export ADMIN_USER="admin"
export ADMIN_PASS="Admin123!"

export BASE_URL="localhost"
export REAL_USER="$(whoami)"
export VER_ES="8"
```

---

## Run the Script

```bash
chmod +x magento.sh
sudo ./magento.sh
```

Magento will be installed at:

```
/var/www/html/magento2
```

Admin panel:

```
http://localhost/admin
```

---

## Manual Installation (Without Script)

### 1. Configure Composer Authentication

```bash
composer config --global http-basic.repo.magento.com PUBLIC_KEY PRIVATE_KEY
```

---

### 2. Install Magento via Composer

```bash
sudo mkdir -p /var/www/html/magento2
sudo chown $USER:www-data /var/www/html/magento2

composer create-project \
--repository-url=https://repo.magento.com/ \
magento/project-community-edition=2.4.7 \
/var/www/html/magento2
```

---

### 3. Set Permissions

```bash
cd /var/www/html/magento2

find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
chmod -R 775 bin/magento
```

---

### 4. Run Magento Setup Install

```bash
php bin/magento setup:install \
--base-url=http://localhost \
--db-host=localhost \
--db-name=magento_db \
--db-user=magento_user \
--db-password=magento_password \
--admin-firstname=Admin \
--admin-lastname=Admin \
--admin-email=admin@example.com \
--admin-user=admin \
--admin-password=Admin123! \
--language=en_US \
--currency=USD \
--timezone=America/Chicago \
--backend-frontname=admin \
--search-engine=elasticsearch8 \
--elasticsearch-host=127.0.0.1 \
--elasticsearch-port=9200 \
--cache-backend=redis \
--cache-backend-redis-server=127.0.0.1 \
--cache-backend-redis-db=0 \
--page-cache=redis \
--page-cache-redis-server=127.0.0.1 \
--page-cache-redis-db=1 \
--session-save=redis \
--session-save-redis-host=127.0.0.1 \
--session-save-redis-db=2
```

---

### 5. Post-Install Tasks

```bash
php bin/magento indexer:reindex
php bin/magento setup:upgrade
php bin/magento setup:static-content:deploy -f
php bin/magento cache:flush
```

---

## Verification

Open browser:

```
http://localhost
```

Admin panel:

```
http://localhost/admin
```

---

## Troubleshooting

### Permission errors

```bash
sudo chown -R $USER:www-data /var/www/html/magento2
```

---

### Magento command not working

```bash
php -v
composer --version
```

---

## Notes

* Designed for Magento development environments
* Requires Magento Marketplace API keys
* Safe to re-run multiple times
* Integrates Redis and Elasticsearch automatically

---