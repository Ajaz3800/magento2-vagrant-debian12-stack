# PHP Setup Script for Magento (Debian 12)

This script installs and configures **PHP for Magento** on Debian 12. It installs PHP with required extensions and prepares the system for Magento compatibility.

The script supports installing a specific PHP version using environment variables.

---

## Features

* Installs selected PHP version
* Installs Magento-required PHP extensions
* Adds official PHP repository (Sury)
* Enables required PHP modules
* Safe to re-run (idempotent)

---

## 🚀 Full Magento Stack Installation (Recommended)

If you want to install the **complete Magento environment** (NGINX, PHP, MySQL, Redis, Varnish, Elasticsearch, etc.), clone the full stack repository and run the installer:

```bash
git clone https://github.com/Ajaz3800/magento2-vagrant-debian12-stack.git
cd magento2-vagrant-debian12-stack
sudo ./install_magento2.sh
```

This PHP script is included automatically in the full setup.

---

## Requirements

* Debian 12
* Root or sudo access
* Internet connection
* Bash shell

---

## Environment Variables

Set the PHP version before running:

```bash
export PHP_VER="8.3"
```

You can change the version if needed (example: 8.2 or 8.1).

---

## Run the Script

```bash
chmod +x PHP.sh
sudo ./PHP.sh
```

---

## Manual Installation (Without Script)

If you want to install PHP manually, follow these steps.

### 1. Add PHP Repository

```bash
sudo apt-get install -y lsb-release apt-transport-https ca-certificates wget gnupg
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt-get update
```

---

### 2. Install PHP and Extensions

Example for PHP 8.3:

```bash
sudo apt-get install -y \
php8.3 php8.3-fpm php8.3-cli php8.3-common \
php8.3-mysql php8.3-mysqli php8.3-curl php8.3-gd \
php8.3-mbstring php8.3-xml php8.3-bcmath php8.3-intl \
php8.3-soap php8.3-zip php8.3-xmlrpc php8.3-gmp \
php8.3-cgi php8.3-redis php-pear php-phpseclib
```

Enable mbstring:

```bash
sudo phpenmod mbstring
```

---

## Verification

Check PHP version:

```bash
php -v
```

Check PHP modules:

```bash
php -m
```

---

## Troubleshooting

### PHP not found after installation

```bash
sudo update-alternatives --set php /usr/bin/php8.3
```

### PHP-FPM not running

```bash
sudo systemctl status php8.3-fpm
sudo systemctl restart php8.3-fpm
```

---

## Notes

* Script installs Magento-compatible PHP extensions
* You can modify extensions inside the script if needed
* Safe to run multiple times

---