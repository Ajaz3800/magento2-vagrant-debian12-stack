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

# ---------- Progress Installer Framework ----------

TOTAL_STEPS=0
CURRENT_STEP=0

init_steps() {
    TOTAL_STEPS=$1
    CURRENT_STEP=0
}

progress_bar() {
    local pid=$1
    local prefix="$2"
    local width=20
    local progress=0

    while kill -0 "$pid" 2>/dev/null; do
        progress=$(( (progress + 2) % 101 ))

        local filled=$((progress * width / 100))
        local empty=$((width - filled))

        printf "\r%-35s [" "$prefix"

        printf "${GREEN}%0.s█${RESET}" $(seq 1 $filled)
        printf "%0.s░" $(seq 1 $empty)

        printf "] %3d%%" "$progress"

        sleep 0.1
    done
}




run_step() {
    local message="$1"
    shift

    CURRENT_STEP=$((CURRENT_STEP + 1))

    local prefix="[${CURRENT_STEP}/${TOTAL_STEPS}] $message"

    set +e
    "$@" >/dev/null 2>&1 &
    local pid=$!
    set -e

    progress_bar "$pid" "$prefix"
    wait "$pid"
    local status=$?

    printf "\r%-35s [${GREEN}████████████████████${RESET}] 100%% " "$prefix"

    if [[ $status -eq 0 ]]; then
        printf "${GREEN}✔${RESET}\n"
    else
        printf "${RED}✖${RESET}\n"
        exit 1
    fi
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