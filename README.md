# Magento 2 Installation Lab (Vagrant + Debian 12)

A complete Magento 2 installation and configuration lab built using **Vagrant + VirtualBox** on **Debian 12**. This project demonstrates a production-like Magento stack with NGINX, PHP 8.3, MySQL 8, Elasticsearch, Redis, Varnish, HTTPS, and PHPMyAdmin.


---

## 📌 Project Overview

This lab automates the setup of a Magento 2 environment inside a virtual machine. It is designed for:

* Learning Magento infrastructure setup
* DevOps practice
* Portfolio demonstration
* YouTube tutorial reference

---

## 🧱 Architecture

![Magento 2 High-Performance Architecture on Debian 12 (Vagrant Lab Environment)](assets/demo-2.gif)

---

## ⚙️ Requirements

Before starting, install the following on your host machine:

* VirtualBox
* Vagrant
* Git
* Minimum 4 GB RAM recommended

---

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/your-username/magento-lab.git
cd magento-lab
```

### 2. Start Virtual Machine

```bash
vagrant up
```

### 3. SSH into VM

```bash
vagrant ssh
```

---

## 🌐 Local Domain Setup

Edit your host machine’s hosts file:

### Linux / macOS

```
/etc/hosts
```

### Windows

```
C:\Windows\System32\drivers\etc\hosts
```

Add:

```
192.168.56.10 test.mgt.com
192.168.56.10 pma.mgt.com
```

---

## 🔐 Access URLs

* Magento Store: https://test.mgt.com
* Magento Admin: https://test.mgt.com/admin
* PHPMyAdmin: https://pma.mgt.com

> Note: Self-signed SSL certificate is used.

---

## 📂 Project Structure

```
magento-lab/
├── Vagrantfile
├── setup.sh
├── nginx/
│   ├── magento.conf
│   └── phpmyadmin.conf
├── varnish/
│   └── default.vcl
├── docs/
│   └── installation.md
└── README.md
```

---

## 🛠️ Features Implemented

* Debian 12 VM provisioning
* Magento 2 installation with sample data
* Elasticsearch integration
* Redis for cache and sessions
* Varnish full-page caching
* NGINX virtual hosts
* HTTPS with self-signed SSL
* PHP-FPM custom pool
* User and permission configuration
* PHPMyAdmin setup

---

## 🎥 Video Tutorial

YouTube walkthrough:

```
[Add your YouTube video link here]
```

---

## 📸 Screenshots

Add screenshots of:

* Magento homepage
* Admin dashboard
* PHPMyAdmin
* Varnish status
* NGINX configuration

---

## 🧪 Testing Checklist

* Magento loads over HTTPS
* Admin panel accessible
* Redis cache working
* Elasticsearch connected
* Varnish caching active
* PHPMyAdmin accessible

---

## 🐛 Troubleshooting

Common fixes:

Restart services:

```bash
sudo systemctl restart nginx
sudo systemctl restart php8.3-fpm
sudo systemctl restart mysql
sudo systemctl restart redis
sudo systemctl restart elasticsearch
```

Clear Magento cache:

```bash
php bin/magento cache:flush
```

---

## 📚 Documentation

Detailed installation guide:

```
docs/installation.md
```

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss your ideas.

---

## 📄 License

This project is licensed under the MIT License.

---

## 👤 Author

**Your Name**

* GitHub: https://github.com/your-username
* LinkedIn: [Add your LinkedIn]
* YouTube: [Add your channel]

---

## ⭐ Support

If you find this project helpful, please give it a star ⭐ on GitHub.