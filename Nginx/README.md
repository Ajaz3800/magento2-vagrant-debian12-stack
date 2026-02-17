# Nginx Setup Script for Magento (Debian 12)

This script installs and configures **Nginx** for a Magento development environment on Debian 12. It installs Nginx (if missing), applies phpMyAdmin and Magento virtual host configurations, updates PHP-FPM sockets, and reloads the server.

The script is designed to work with Magento + Varnish reverse proxy architecture.

---

## Features

* Installs Nginx automatically if missing
* Configures phpMyAdmin virtual host
* Configures Magento front & back virtual hosts
* Automatically updates PHP-FPM version
* Enables Nginx sites safely
* Tests configuration before reload
* Safe to re-run (idempotent)

---

## 🚀 Full Magento Stack Installation (Recommended)

If you want to install the **complete Magento environment automatically**, run:

```bash
git clone https://github.com/Ajaz3800/magento2-vagrant-debian12-stack.git
cd magento2-vagrant-debian12-stack
sudo ./install_magento2.sh
```

This Nginx script is included in the full setup.

---

## Requirements

* Debian 12
* PHP-FPM installed
* Root or sudo access
* Magento + phpMyAdmin configuration samples present

---

## Environment Variables

Set required variables:

```bash
export PHP_VER="8.3"
export BASE_URL="magento.local"
export PMA_URL="pma.local"
```

---

## Run the Script

```bash
chmod +x nginx.sh
sudo ./nginx.sh
```

---

## Manual Installation (Without Script)

### 1. Install Nginx

```bash
sudo apt-get install -y nginx
```

---

### 2. Copy phpMyAdmin Config

```bash
sudo cp ./Nginx/config/phpmyadmin.conf.sample \
/etc/nginx/sites-available/phpmyadmin.conf

sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf \
/etc/nginx/sites-enabled/
```

---

### 3. Copy Magento Configs

```bash
sudo cp ./Nginx/config/magento2-back.conf.sample \
/etc/nginx/sites-available/magento2-back.conf

sudo cp ./Nginx/config/magento2-front.conf.sample \
/etc/nginx/sites-available/magento2-front.conf

sudo ln -s /etc/nginx/sites-available/magento2-*.conf \
/etc/nginx/sites-enabled/
```

Update PHP-FPM socket inside configs:

```
php8.3-fpm.sock
```

---

### 4. Test and Reload

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## Verification

Open browser:

```
http://magento.local
http://pma.local
```

---

## Troubleshooting

### Nginx config error

```bash
sudo nginx -t
```

---

### Service not running

```bash
sudo systemctl status nginx
sudo systemctl restart nginx
```

---

## Notes

* Designed for Magento + Varnish architecture
* Requires valid config sample files
* Safe to run multiple times

---