## Configure Varnish Full Page Cache for Magento 2

This script installs and configures **Varnish Cache** and connects it with Magento 2 for full-page caching.

It automatically:

* Installs Varnish (if not installed)
* Configures Magento to use Varnish
* Flushes Magento cache
* Generates Magento VCL file
* Restarts Varnish service

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

If you want to configure Varnish manually, follow these steps:

#### 1. Install Varnish

```bash
sudo apt update
sudo apt install varnish -y
```

---

#### 2. Configure Magento to Use Varnish

Go to your Magento directory:

```bash
cd /var/www/html/magento2
```

Enable Varnish caching:

```bash
sudo -u www-data php bin/magento config:set system/full_page_cache/caching_application 2
```

Flush Magento cache:

```bash
sudo -u www-data php bin/magento cache:flush
```

---

#### 3. Generate Magento VCL File

```bash
sudo -u www-data php bin/magento varnish:vcl:generate | sudo tee /etc/varnish/default.vcl
```

---

#### 4. Restart Varnish

```bash
sudo systemctl restart varnish
```

---

### Verify Varnish Is Running

```bash
sudo systemctl status varnish
```

You should see:

```
active (running)
```

---

### 🚀 Done!

Varnish is now configured as a full-page cache for Magento 2.
Your Magento store should load significantly faster.
