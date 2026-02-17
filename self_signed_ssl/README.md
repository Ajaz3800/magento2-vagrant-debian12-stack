## Enable HTTPS with Self-Signed SSL Certificates

This script generates self-signed SSL certificates and enables HTTPS for:

* Magento 2 storefront
* phpMyAdmin

It also:

* Creates SSL certificates
* Configures Nginx virtual hosts
* Enables HTTPS proxy via Varnish
* Updates Magento base URLs to HTTPS
* Reloads Nginx

---

## 🚀 Full Magento Stack Installation (Recommended)

If you want to install the **complete Magento environment automatically**, run:

```bash
git clone https://github.com/Ajaz3800/magento2-vagrant-debian12-stack.git
cd magento2-vagrant-debian12-stack
sudo ./install_magento2.sh
```

This hosts update script is included in the full setup.

---

### Manual Setup (Without Script)

If you prefer to configure SSL manually, follow these steps:

---

#### 1. Create SSL Directory

```bash
sudo mkdir -p /etc/nginx/ssl
```

---

#### 2. Generate SSL for phpMyAdmin

```bash
sudo openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/phpmyadmin.key \
  -out /etc/nginx/ssl/phpmyadmin.crt
```

---

#### 3. Generate SSL for Magento

```bash
sudo openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/magento.key \
  -out /etc/nginx/ssl/magento.crt
```

---

#### 4. Configure Nginx for HTTPS

Create phpMyAdmin config:

```bash
sudo nano /etc/nginx/sites-available/phpmyadmin.conf
```

Add SSL server block and save.

---

Create Magento HTTPS config:

```bash
sudo nano /etc/nginx/sites-available/magento2-front.conf
```

Enable sites:

```bash
sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/magento2-front.conf /etc/nginx/sites-enabled/
```

---

#### 5. Reload Nginx

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

#### 6. Update Magento URLs to HTTPS

```bash
cd /var/www/html/magento2

php bin/magento config:set web/unsecure/base_url https://your-domain/
php bin/magento config:set web/secure/base_url https://your-domain/
php bin/magento config:set web/secure/use_in_frontend 1
php bin/magento config:set web/secure/use_in_adminhtml 1
php bin/magento cache:flush
```

---

### Browser Warning

Because this is a **self-signed certificate**, your browser will show a security warning.

This is normal for development environments.

---

### Done!

HTTPS is now enabled for Magento 2 and phpMyAdmin.
