#!/bin/bash

# ANSI Color Library

export RED="\e[31m"
export GREEN="\e[32m"
export YELLOW="\e[33m"
export BLUE="\e[34m"
export MAGENTA="\e[35m"
export CYAN="\e[36m"
export RESET="\e[0m"

# Helper functions

color_echo() {
local color=$1
shift
echo -e "${color}$*${RESET}"
}