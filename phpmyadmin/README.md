# phpMyAdmin Setup Script for Magento (Debian 12)

This script installs and configures **phpMyAdmin** on Debian 12. It downloads the latest version, extracts it into the web directory, and prepares permissions for Magento environments.

phpMyAdmin provides a web-based interface to manage MySQL databases easily.

---

## Features

* Downloads latest phpMyAdmin release
* Installs into `/var/www/html/phpmyadmin`
* Automatically configures basic setup
* Sets correct file permissions
* Safe to re-run (idempotent)

---

## 🚀 Full Magento Stack Installation (Recommended)

If you want to install the **complete Magento environment** (NGINX, PHP, MySQL, Redis, Varnish, Elasticsearch, etc.), clone the full stack repository and run the installer:

```bash
git clone https://github.com/Ajaz3800/magento2-vagrant-debian12-stack.git
cd magento2-vagrant-debian12-stack
sudo ./install_magento2.sh
```

This phpMyAdmin script is included automatically in the full setup.

---

## Requirements

* Debian 12
* PHP installed and running
* Web server (NGINX or Apache)
* Root or sudo access
* Internet connection

---

## Run the Script

```bash
chmod +x phpmyadmin.sh
sudo ./phpmyadmin.sh
```

After installation, access phpMyAdmin in your browser:

```
http://your-server-ip/phpmyadmin
```

---

## Manual Installation (Without Script)

If you want to install phpMyAdmin manually, follow these steps.

### 1. Download phpMyAdmin

```bash
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
```

---

### 2. Extract Files

```bash
sudo mkdir -p /var/www/html
sudo tar xzf phpMyAdmin-latest-all-languages.tar.gz -C /var/www/html
sudo mv /var/www/html/phpMyAdmin-* /var/www/html/phpmyadmin
```

---

### 3. Configure phpMyAdmin

```bash
sudo cp /var/www/html/phpmyadmin/config.sample.inc.php \
/var/www/html/phpmyadmin/config.inc.php
```

---

### 4. Set Permissions

```bash
sudo chown -R www-data:www-data /var/www/html/phpmyadmin
sudo chmod -R 755 /var/www/html/phpmyadmin
```

---

## Verification

Open your browser and visit:

```
http://your-server-ip/phpmyadmin
```

Login using your MySQL credentials.

---

## Troubleshooting

### phpMyAdmin page not loading

Check web server status:

```bash
sudo systemctl status nginx
```

or

```bash
sudo systemctl status apache2
```

Restart if needed.

---

### Permission errors

```bash
sudo chown -R www-data:www-data /var/www/html/phpmyadmin
```

---

## Notes

* Installs latest phpMyAdmin version
* Designed for Magento development environments
* Safe to run multiple times

---