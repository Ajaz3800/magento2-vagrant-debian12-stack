# Composer Setup Script for Magento (Debian 12)

This script installs **Composer**, the PHP dependency manager required for Magento installation and package management.

Composer is used to download Magento core files and manage PHP dependencies.

---

## Features

* Installs latest Composer version
* Installs Composer globally
* Automatic cleanup after installation
* Safe to re-run (idempotent)

---

## 🚀 Full Magento Stack Installation (Recommended)

If you want to install the **complete Magento environment** (NGINX, PHP, MySQL, Redis, Varnish, Elasticsearch, etc.), clone the full stack repository and run the installer:

```bash
git clone https://github.com/Ajaz3800/magento2-vagrant-debian12-stack.git
cd magento2-vagrant-debian12-stack
sudo ./install_magento2.sh
```

This Composer script is included automatically in the full setup.

---

## Requirements

* Debian 12
* PHP installed and working
* Root or sudo access
* Internet connection

---

## Run the Script

```bash
chmod +x composer.sh
sudo ./composer.sh
```

---

## Manual Installation (Without Script)

If you want to install Composer manually, follow these steps.

### 1. Download Composer Installer

```bash
curl -sS https://getcomposer.org/installer -o composer-setup.php
```

---

### 2. Install Composer Globally

```bash
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php
```

---

## Verification

Check Composer version:

```bash
composer --version
```

---

## Troubleshooting

### Composer not found

```bash
export PATH=$PATH:/usr/local/bin
```

---

### Permission issues

```bash
sudo chown -R $USER:$USER ~/.composer
```

---

## Notes

* Required for Magento installation
* Installed globally for all users
* Safe to run multiple times

---