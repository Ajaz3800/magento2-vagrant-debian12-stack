#!/bin/bash

LOG_FILE="/var/log/my_script.log"

log() {
local level=$1
shift
local message="$*"
local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

```
echo "$timestamp [$level] $message" >> "$LOG_FILE"
```

}

info() {
log "INFO" "$@"
color_echo $BLUE "[INFO] $*"
}

success() {
log "SUCCESS" "$@"
color_echo $GREEN "[SUCCESS] $*"
}

warn() {
log "WARNING" "$@"
color_echo $YELLOW "[WARNING] $*"
}

error() {
log "ERROR" "$@"
color_echo $RED "[ERROR] $*"
exit 1
}