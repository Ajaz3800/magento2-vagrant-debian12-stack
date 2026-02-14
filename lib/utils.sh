#!/bin/bash

# ==========================================

# utils.sh - Reusable Bash Utilities

# ==========================================

# ---------- Check Root ----------

require_root() {
if [[ "$EUID" -ne 0 ]]; then
color_echo $RED "This script must be run as root."
exit 1
fi
}

# ---------- Check Command Exists ----------

check_command() {
local cmd=$1

```
if ! command -v "$cmd" &> /dev/null; then
    color_echo $RED "Required command not found: $cmd"
    exit 1
fi
```

}

# ---------- Retry Function ----------

retry() {
    local attempts=$1
    shift
    
    local count=0
    local exit_code=0
    
    for ((count=1; count<=attempts; count++)); do
        # Run command, capturing output and exit code
        if "$@"; then
            return 0
        else
            exit_code=$?
            
            if [[ $count -ge $attempts ]]; then
                color_echo $RED "Command failed after $attempts attempts."
                return $exit_code
            fi
            
            color_echo $YELLOW "Command failed. Retrying ($count/$attempts)..."
            sleep 2
        fi
    done
}


# ---------- User Confirmation ----------

# ---------- Safe User Confirmation (won't exit with set -e) ----------

safe_confirm() {
    local prompt="$1"
    read -rp "$prompt (y/n): " response
    case "${response,,}" in
        yes|y) echo "yes" ;;
        *) echo "no" ;;
    esac
}

# ---------- Backup File ----------

backup_file() {
local file=$1

```
if [[ -f "$file" ]]; then
    cp "$file" "${file}.bak.$(date +%s)"
    color_echo $GREEN "Backup created: ${file}.bak"
fi
```

}

# ---------- Spinner ----------

spinner() {
local pid=$1
local delay=0.1
local spinstr='|/-\'

```
while ps -p "$pid" > /dev/null 2>&1; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
done
printf "    \b\b\b\b"
```

}

# ---------- Network Check ----------

check_network() {
if ! ping -c 1 8.8.8.8 &> /dev/null; then
color_echo $RED "Network is unreachable."
exit 1
fi
}

# ---------- Safe Run Command ----------

run_cmd() {
echo "Running: $*"
"$@"
local status=$?

```
if [[ $status -ne 0 ]]; then
    color_echo $RED "Command failed with exit code $status"
    exit $status
fi
```

}