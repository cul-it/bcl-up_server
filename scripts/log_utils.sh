#!/usr/bin/env bash
###########################################
## Utility file used for logging methods ##
###########################################

###########################
##   ANSI Color Codes    ##
###########################
# Name      | Code        |
# ----------|-------------|
# Black     | \033[0;30m  |
# Red       | \033[0;31m  |
# Green     | \033[0;32m  |
# Yellow    | \033[0;33m  |
# Blue      | \033[0;34m  |
# Magenta   | \033[0;35m  |
# Cyan      | \033[0;36m  |
# White     | \033[0;37m  |
# No Color  | \033[0m     |
# =========================

print_header() {
  local NC='\033[0m'
  local BLUE='\033[0;34m'
  local MAGENTA='\033[0;35m'
  local line_length=70

  local message="$1"
  local underline="$2" # optional, e.g., "From image: v2.0.0"

  echo " "
  echo -e "${BLUE}$(printf '%*s\n' $line_length '' | tr ' ' '=')${NC}"
  printf "%s\n" "$(echo -e "${MAGENTA}$(printf "%*s" $(( (${#message} + $line_length) / 2)) "$message")${NC}")"

  if [ -n "$underline" ]; then
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    printf "%s\n" "$(echo -e "${MAGENTA}$(printf "%*s" $(( (${#underline} + $line_length) / 2)) "$underline")${NC}")"
  fi

  echo -e "${BLUE}$(printf '%*s\n' $line_length '' | tr ' ' '=')${NC}"
}

print_jenkins_stage() {
  local NC='\033[0m'
  local BOLD_CYAN='\033[1;36m'
  local line_length=70

  local message="$1"
  local underline="$2" # optional, e.g., "From image: v2.0.0"

  echo " "
  echo -e "${BOLD_CYAN}$(printf '%*s\n' $line_length '' | tr ' ' '=')${NC}"
  printf "%s\n" "$(echo -e "${BOLD_CYAN}$(printf "%*s" $(( (${#message} + $line_length) / 2)) "$message")${NC}")"

  if [ -n "$underline" ]; then
    echo -e "${BOLD_CYAN}---------------------------------------------------------------------${NC}"
    printf "%s\n" "$(echo -e "${BOLD_CYAN}$(printf "%*s" $(( (${#underline} + $line_length) / 2)) "$underline")${NC}")"
  fi

  echo -e "${BOLD_CYAN}$(printf '%*s\n' $line_length '' | tr ' ' '=')${NC}"
}

print_msg() {
  local MAGENTA='\033[0;35m'
  local NC='\033[0m' # No Color
  echo -e "${MAGENTA}$1${NC}"
}

print_line() {
  local BLUE='\033[0;34m'
  local NC='\033[0m' # No Color
  echo -e "${BLUE}%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%${NC}"
}

print_list() {
    local BOLD_CYAN='\033[1;36m'
    local NC='\033[0m' # No Color
    echo " "
    echo -e "${BOLD_CYAN}%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%${NC}"
    echo -e "${BOLD_CYAN}$1${NC}"
}

print_error() {
  local RED='\033[0;31m'
  local NC='\033[0m' # No Color
  echo -e "${RED}$1${NC}"
}

print_success() {
  local GREEN='\033[0;32m'
  local NC='\033[0m' # No Color
  echo -e "${GREEN}$1${NC}"
}