# MySQL 8 Setup Script for Magento (Debian 12)

This script installs and configures **MySQL 8** for Magento on Debian 12. It automates installation, root password setup, database creation, and Magento-specific MySQL configuration.

## Features

* Installs MySQL 8 (if not already installed)
* Configures MySQL root authentication
* Creates Magento database and user
* Grants proper privileges
* Enables Magento-required MySQL settings
* Safe to re-run (idempotent)

---

## 🚀 Full Magento Stack Installation (Recommended)

If you want to install the **complete Magento environment** (NGINX, PHP, MySQL, Redis, Varnish, Elasticsearch, etc.), clone the full stack repository and run the installer:

[magento2-vagrant-debian12-stack](https://github.com/Ajaz3800/magento2-vagrant-debian12-stack)
```bash
git clone https://github.com/Ajaz3800/magento2-vagrant-debian12-stack.git
cd magento2-vagrant-debian12-stack
sudo ./install_magento2.sh
```

This MySQL script is included automatically in the full setup.

---

## Requirements

* Debian 12
* Root or sudo access
* Internet connection
* Bash shell

---

## Environment Variables

Before running the script, set the following variables:

```bash
export MYSQL_ROOT_PASS="root_password"
export MYSQL_DB_NAME="magento_db"
export MYSQL_DB_USER="magento_user"
export MYSQL_DB_PASS="magento_password"
export REAL_USER="$(whoami)"
```

---

## Run the Script

```bash
chmod +x MySQL.sh
sudo ./MySQL.sh
```

---

## Manual Installation (Without Script)

If you want to install manually, follow these steps.

### 1. Install MySQL 8 Repository

```bash
wget https://dev.mysql.com/get/mysql-apt-config_0.8.36-1_all.deb
sudo dpkg -i mysql-apt-config_0.8.36-1_all.deb
sudo apt-get update
```

### 2. Install MySQL Server

```bash
sudo apt-get install -y mysql-server
```

### 3. Set MySQL Root Password

```bash
sudo mysql
```

Inside MySQL shell:

```sql
ALTER USER 'root'@'localhost'
IDENTIFIED WITH caching_sha2_password
BY 'your_root_password';

FLUSH PRIVILEGES;
EXIT;
```

---

### 4. Create Magento Database and User

```bash
mysql -u root -p
```

Inside MySQL:

```sql
CREATE DATABASE magento_db;
CREATE USER 'magento_user'@'localhost' IDENTIFIED BY 'magento_password';
GRANT ALL PRIVILEGES ON magento_db.* TO 'magento_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

### 5. Enable Magento MySQL Configuration

Edit MySQL config:

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

Add:

```
[mysqld]
log_bin_trust_function_creators=1
```

Restart MySQL:

```bash
sudo systemctl restart mysql
```

---

## Verification

Test database connection:

```bash
mysql -u magento_user -p magento_db
```

---

## Troubleshooting

### MySQL service not running

```bash
sudo systemctl status mysql
sudo systemctl restart mysql
```

### Cannot login as root

```bash
sudo mysql
```

Reset password again using SQL commands.

---

## Notes

* Script is designed for Magento compatibility
* Safe to run multiple times
* Will skip already completed steps

---