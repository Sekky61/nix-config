#!/usr/bin/env bash
# =============================================================================
# bash_utils.sh - Ergonomic utility functions for bash scripts
# =============================================================================

# Set to exit immediately if a command exits with a non-zero status
# and to treat unset variables as an error
set -eo pipefail

# Prevent this file from being sourced twice
[[ "${BASH_UTILS_LOADED:-}" == "true" ]] && return 0
export BASH_UTILS_LOADED=true

# =============================================================================
# Color and formatting utilities
# =============================================================================

# Terminal color codes
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export GRAY='\033[0;37m'
export BOLD='\033[1m'
export RESET='\033[0m'

# Print colorized messages
log_info() { printf "${BLUE}INFO:${RESET} %s\n" "$*"; }
log_success() { printf "${GREEN}SUCCESS:${RESET} %s\n" "$*"; }
log_warning() { printf "${YELLOW}WARNING:${RESET} %s\n" "$*" >&2; }
log_error() { printf "${RED}ERROR:${RESET} %s\n" "$*" >&2; }
log_debug() { [[ "${DEBUG:-false}" == "true" ]] && printf "${GRAY}DEBUG:${RESET} %s\n" "$*"; }

# Create a header for sections
header() {
  local msg="$1"
  local char="${2:-=}"
  local line
  printf -v line "%*s" "${#msg}" "" 
  line=${line// /$char}
  echo -e "\n${BOLD}${msg}${RESET}\n${line}"
}

# =============================================================================
# Directory and path utilities
# =============================================================================

# Get the directory of the script being sourced
get_script_dir() {
  if [[ -n "$BASH_SOURCE" ]]; then
    dirname "$(realpath "${BASH_SOURCE[0]}")"
  else
    pwd
  fi
}

# Create directory if it doesn't exist
ensure_dir() {
  local dir="$1"
  [[ -d "$dir" ]] || mkdir -p "$dir"
}

# Add a directory to PATH if it exists and isn't already in PATH
add_to_path() {
  local dir="$1"
  if [[ -d "$dir" && ":${PATH}:" != *":${dir}:"* ]]; then
    export PATH="$dir:$PATH"
    return 0
  fi
  return 1
}

# Generate a temporary file or directory with automatic cleanup
mktempfile() {
  local tmpfile
  tmpfile=$(mktemp)
  trap "rm -f '$tmpfile'" EXIT
  echo "$tmpfile"
}

mktempdir() {
  local tmpdir
  tmpdir=$(mktemp -d)
  trap "rm -rf '$tmpdir'" EXIT
  echo "$tmpdir"
}

# =============================================================================
# File operations
# =============================================================================

# Check if a file exists and is readable
is_readable() {
  [[ -r "$1" ]]
}

# Check if a file exists and is writable
is_writable() {
  [[ -w "$1" ]]
}

# Check if a file exists and is executable
is_executable() {
  [[ -x "$1" ]]
}

# Check if a string is in a file
contains_string() {
  local file="$1"
  local str="$2"
  grep -q "$str" "$file" 2>/dev/null
}

# Safely write to a file with backup
safe_write() {
  local file="$1"
  local content="$2"
  local backup="${file}.bak"
  
  if [[ -f "$file" ]]; then
    cp "$file" "$backup"
  fi
  
  echo "$content" > "$file"
}

# =============================================================================
# Command and process utilities
# =============================================================================

# Check if a command exists
command_exists() {
  command -v "$1" &>/dev/null
}

# Run a command with a timeout
run_with_timeout() {
  local timeout="$1"
  shift
  
  if command_exists timeout; then
    timeout "$timeout" "$@"
  else
    "$@" &
    local pid=$!
    
    (
      sleep "$timeout"
      kill -TERM "$pid" 2>/dev/null || true
    ) &
    local watchdog=$!
    
    wait "$pid" 2>/dev/null || true
    kill -TERM "$watchdog" 2>/dev/null || true
  fi
}

# Run a command silently (no output)
run_silent() {
  "$@" >/dev/null 2>&1
}

# Get the PID of a process running a specific command
get_pid_by_command() {
  local cmd="$1"
  pgrep -f "$cmd" || echo ""
}

# Kill processes by command pattern
kill_process_by_command() {
  local cmd="$1"
  local signal="${2:-TERM}"
  local pids
  
  pids=$(pgrep -f "$cmd")
  
  if [[ -n "$pids" ]]; then
    log_info "Killing processes matching '$cmd' with signal $signal"
    echo "$pids" | xargs kill -"$signal"
    return 0
  else
    log_debug "No processes found matching '$cmd'"
    return 1
  fi
}

# =============================================================================
# Script execution control
# =============================================================================

# Require root privileges
require_root() {
  if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root"
    exit 1
  fi
}

# Require a specific command to be available
require_command() {
  local cmd="$1"
  local pkg="${2:-$cmd}"
  
  if ! command_exists "$cmd"; then
    log_error "Required command '$cmd' not found. Please install $pkg."
    exit 1
  fi
}

# Retry a command a few times before giving up
retry() {
  local retries="${1:-3}"
  local wait="${2:-1}"
  shift 2
  
  local count=0
  until "$@"; do
    exit_code=$?
    count=$((count + 1))
    
    if [[ $count -lt $retries ]]; then
      log_warning "Command failed (attempt $count/$retries). Retrying in ${wait}s..."
      sleep "$wait"
    else
      log_error "Command failed after $retries attempts."
      return $exit_code
    fi
  done
  
  return 0
}

# Run with exclusive lock to prevent multiple instances
with_lock() {
  local lock_name="$1"
  shift
  
  local lock_file="/tmp/bash_utils_${lock_name}.lock"
  
  (
    # Try to acquire lock
    if ! flock -n 9; then
      log_error "Another instance of this script is already running."
      exit 1
    fi
    
    # Run the command
    "$@"
  ) 9>"$lock_file"
}

# =============================================================================
# Input/output utilities
# =============================================================================

# Ask for confirmation
confirm() {
  local prompt="${1:-Are you sure?}"
  local default="${2:-y}"
  
  if [[ "$default" =~ ^[Yy] ]]; then
    local yn_prompt="[Y/n]"
  else
    local yn_prompt="[y/N]"
  fi
  
  read -r -p "$prompt $yn_prompt " answer
  answer=${answer:-$default}
  
  [[ "$answer" =~ ^[Yy] ]]
}

# Get user input with a prompt and optional default value
get_input() {
  local prompt="$1"
  local default="$2"
  local result
  
  if [[ -n "$default" ]]; then
    read -r -p "$prompt [$default]: " result
    result=${result:-$default}
  else
    read -r -p "$prompt: " result
  fi
  
  echo "$result"
}

# Get password without echoing to screen
get_password() {
  local prompt="${1:-Password:}"
  local password
  
  read -r -s -p "$prompt " password
  echo >&2 # Move to a new line since read -s doesn't do this
  echo "$password"
}

# Display a spinner while running a command
spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  
  while ps a | awk '{print $1}' | grep -q "$pid"; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# Display a progress bar
progress_bar() {
  local current="$1"
  local total="$2"
  local width="${3:-50}"
  
  local percent=$((current * 100 / total))
  local completed=$((width * current / total))
  local remaining=$((width - completed))
  
  printf "\r["
  printf "%${completed}s" | tr ' ' '#'
  printf "%${remaining}s" | tr ' ' ' '
  printf "] %d%%" "$percent"
}

# =============================================================================
# String manipulation
# =============================================================================

# Trim whitespace from string
trim() {
  local var="$*"
  # Remove leading whitespace
  var="${var#"${var%%[![:space:]]*}"}"
  # Remove trailing whitespace
  var="${var%"${var##*[![:space:]]}"}"
  echo -n "$var"
}

# Convert string to lowercase
lowercase() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Convert string to uppercase
uppercase() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Generate a random string
random_string() {
  local length="${1:-32}"
  tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
}

# =============================================================================
# Network utilities
# =============================================================================

# Check if a URL is reachable
is_url_reachable() {
  local url="$1"
  local timeout="${2:-5}"
  
  if command_exists curl; then
    curl --output /dev/null --silent --head --fail --max-time "$timeout" "$url"
  elif command_exists wget; then
    wget --spider --quiet --timeout="$timeout" "$url"
  else
    log_error "Neither curl nor wget is available"
    return 1
  fi
}

# Get external IP address
get_external_ip() {
  if command_exists curl; then
    curl -s https://ifconfig.me
  elif command_exists wget; then
    wget -qO- https://ifconfig.me
  else
    log_error "Neither curl nor wget is available"
    return 1
  fi
}

# Wait for port to be available
wait_for_port() {
  local host="$1"
  local port="$2"
  local timeout="${3:-30}"
  local interval="${4:-1}"
  
  local end_time=$(($(date +%s) + timeout))
  
  while [[ $(date +%s) -lt $end_time ]]; do
    if (echo > "/dev/tcp/$host/$port") >/dev/null 2>&1; then
      return 0
    fi
    sleep "$interval"
  done
  
  return 1
}

# Find an available port
find_available_port() {
  local start_port="${1:-8000}"
  local end_port="${2:-9000}"
  
  for port in $(seq "$start_port" "$end_port"); do
    if ! (echo > "/dev/tcp/127.0.0.1/$port") >/dev/null 2>&1; then
      echo "$port"
      return 0
    fi
  done
  
  return 1
}

# =============================================================================
# Date and time utilities
# =============================================================================

# Get current timestamp in seconds
timestamp() {
  date +%s
}

# Format a date
format_date() {
  local format="${1:-%Y-%m-%d %H:%M:%S}"
  local date_str="${2:-now}"
  
  date -d "$date_str" +"$format" 2>/dev/null || date +"$format"
}

# Convert seconds to human-readable time
seconds_to_human() {
  local seconds="$1"
  local days=$((seconds / 86400))
  local hours=$(( (seconds % 86400) / 3600 ))
  local minutes=$(( (seconds % 3600) / 60 ))
  seconds=$((seconds % 60))
  
  (( days > 0 )) && echo -n "${days}d "
  (( hours > 0 )) && echo -n "${hours}h "
  (( minutes > 0 )) && echo -n "${minutes}m "
  echo "${seconds}s"
}

# =============================================================================
# Array utilities
# =============================================================================

# Check if an element is in an array
in_array() {
  local needle="$1"
  shift
  
  for element in "$@"; do
    [[ "$element" == "$needle" ]] && return 0
  done
  
  return 1
}

# Join array elements with a delimiter
join_by() {
  local delimiter="$1"
  shift
  local first="$1"
  shift
  
  printf "%s" "$first" "${@/#/$delimiter}"
}

# Remove duplicates from an array
unique_array() {
  local -n input_array="$1"
  local -a unique_elements
  
  for item in "${input_array[@]}"; do
    if ! in_array "$item" "${unique_elements[@]}"; then
      unique_elements+=("$item")
    fi
  done
  
  input_array=("${unique_elements[@]}")
}

# =============================================================================
# OS detection and system utilities
# =============================================================================

# Get OS type
get_os() {
  local os
  
  case "$(uname)" in
    Linux)
      if [ -f /etc/os-release ]; then
        os=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
      else
        os="linux"
      fi
      ;;
    Darwin)
      os="macos"
      ;;
    CYGWIN*|MINGW*|MSYS*)
      os="windows"
      ;;
    *)
      os="unknown"
      ;;
  esac
  
  echo "$os"
}

# Check if running on Linux
is_linux() {
  [[ "$(uname)" == "Linux" ]]
}

# Check if running on macOS
is_macos() {
  [[ "$(uname)" == "Darwin" ]]
}

# Check if running on Windows (WSL or MSYS/MINGW)
is_windows() {
  [[ "$(uname)" == *MINGW* ]] || [[ "$(uname)" == *CYGWIN* ]] || grep -q Microsoft /proc/version 2>/dev/null
}

# Get system memory info in MB
get_system_memory() {
  if is_linux; then
    free -m | awk '/^Mem:/{print $2 " total",$3 " used",$4 " free",$7 " available"}'
  elif is_macos; then
    vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages free: (\d+)/ and printf("%.2f free\n", $1 * $size / 1048576);'
  fi
}

# Get CPU usage percentage
get_cpu_usage() {
  if is_linux; then
    top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4 "%"}'
  elif is_macos; then
    top -l 1 | grep "CPU usage" | awk '{print $3}'
  fi
}

# Get disk usage
get_disk_usage() {
  local path="${1:-/}"
  df -h "$path" | awk 'NR==2 {print $5 " used, " $4 " free"}'
}

# =============================================================================
# Error handling and debugging
# =============================================================================

# Enable debug mode
enable_debug() {
  export DEBUG=true
  set -x
}

# Disable debug mode
disable_debug() {
  export DEBUG=false
  set +x
}

# Set up error trapping with call stack
enable_error_trapping() {
  trap 'error_handler $LINENO $?' ERR
  
  error_handler() {
    local line=$1
    local exit_code=$2
    local command
    
    log_error "Error at line $line, exit code $exit_code"
    
    # Print call stack
    log_error "Call stack:"
    local i=0
    local frame
    while frame=$(caller $i); do
      log_error "  $frame"
      ((i++))
    done
    
    exit "$exit_code"
  }
}

# =============================================================================
# Cleanup functions
# =============================================================================

# Register cleanup function to be called on exit
register_cleanup() {
  local func="$1"
  
  # Create the cleanup array if it doesn't exist
  if [[ -z "${CLEANUP_FUNCTIONS[*]:-}" ]]; then
    declare -a CLEANUP_FUNCTIONS
  fi
  
  CLEANUP_FUNCTIONS+=("$func")
  
  # Set the trap if not already set
  if [[ -z "${CLEANUP_TRAP_SET:-}" ]]; then
    trap run_cleanup EXIT
    CLEANUP_TRAP_SET=true
  fi
}

# Run all registered cleanup functions
run_cleanup() {
  if [[ -n "${CLEANUP_FUNCTIONS[*]:-}" ]]; then
    log_debug "Running cleanup functions..."
    
    # Run in reverse order
    for ((i=${#CLEANUP_FUNCTIONS[@]}-1; i>=0; i--)); do
      ${CLEANUP_FUNCTIONS[i]}
    done
  fi
}

# =============================================================================
# Configuration file handling
# =============================================================================

# Load key-value pairs from a config file
load_config() {
  local config_file="$1"
  local prefix="${2:-}"
  
  if [[ ! -f "$config_file" ]]; then
    log_error "Config file not found: $config_file"
    return 1
  fi
  
  while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$key" ]] && continue
    
    # Remove leading/trailing whitespace
    key=$(trim "$key")
    value=$(trim "$value")
    
    # Export variable with optional prefix
    if [[ -n "$prefix" ]]; then
      export "${prefix}${key}"="$value"
    else
      export "$key"="$value"
    fi
  done < "$config_file"
}
