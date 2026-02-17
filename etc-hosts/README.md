# Hosts File Update Script (Debian 12)

This script automatically updates the system **/etc/hosts** file to map your Magento and phpMyAdmin domains to localhost.

It ensures your development URLs work correctly in the browser without manual editing.

---

## Features

* Automatically backs up `/etc/hosts`
* Removes old duplicate entries
* Adds Magento and phpMyAdmin domains
* Requires root privileges for safety
* Safe to re-run (idempotent)

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

## Requirements

* Debian 12
* Root or sudo access

---

## Environment Variables

Set domain names before running:

```bash
export BASE_URL="magento.local"
export PMA_URL="pma.local"
```

You can change these domains as needed.

---

## Run the Script

```bash
chmod +x hosts.sh
sudo ./hosts.sh
```

---

## Manual Configuration (Without Script)

If you want to edit manually:

### 1. Open Hosts File

```bash
sudo nano /etc/hosts
```

---

### 2. Add Domain Entries

```
127.0.0.1    magento.local
127.0.0.1    pma.local
```

Save and exit.

---

## Verification

Test domain resolution:

```bash
ping magento.local
ping pma.local
```

Both should resolve to:

```
127.0.0.1
```

---

## Troubleshooting

### Changes not reflected

Flush DNS cache:

```bash
sudo systemd-resolve --flush-caches
```

Or restart network:

```bash
sudo systemctl restart NetworkManager
```

---

## Notes

* Script creates automatic backups of `/etc/hosts`
* Designed for local Magento development
* Safe to run multiple times

---