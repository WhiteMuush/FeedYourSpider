#!/usr/bin/env bash
# lib/installer.sh — Logging, prompts, and the package-manager dispatcher
# that makes "ensure tool X is installed" a one-liner.

if [[ -n "${FEEDYOURSPIDER_INSTALLER_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_INSTALLER_LOADED=1

# --- Logging helpers --------------------------------------------------------

log_step() {
    printf '%b\n' "${BRIGHT_MAGENTA}${BOLD}==>${RESET} ${BRIGHT_MAGENTA}$*${RESET}"
}

log_info() {
    printf '%b\n' "${DIM}$*${RESET}"
}

log_warn() {
    printf '%b\n' "${BRIGHT_RED}${BOLD}!${RESET} ${BRIGHT_RED}$*${RESET}" >&2
}

log_error() {
    printf '%b\n' "${BRIGHT_RED}${BOLD}x ${RESET}${BRIGHT_RED}$*${RESET}" >&2
}

log_success() {
    printf '%b\n' "${BRIGHT_GREEN}${BOLD}ok${RESET} ${BRIGHT_GREEN}$*${RESET}"
}

# --- Prompts ----------------------------------------------------------------

# Ask for a free-form value. Returns the value via stdout. An empty answer
# is allowed unless the caller validates.
# Usage: target=$(prompt_value "Target (ip/host)")
prompt_value() {
    local prompt="$1"
    local default="${2:-}"
    local hint=""
    [[ -n "$default" ]] && hint=" (${default})"
    local answer
    read -rp $'\n'"${prompt}${hint} > " answer
    if [[ -z "$answer" && -n "$default" ]]; then
        answer="$default"
    fi
    printf '%s' "$answer"
}

# Yes/no prompt. Returns 0 for yes, 1 for no. Default = yes if blank.
# Usage: if prompt_yesno "Continue?"; then ... fi
prompt_yesno() {
    local prompt="$1"
    local answer
    read -rp $'\n'"${prompt} [Y/n] > " answer
    case "$answer" in
        ""|[Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

# Numbered-choice prompt. Returns the chosen number via stdout.
# Usage: pick=$(prompt_choice "Scan type" "Quick" "Service" "Aggressive")
prompt_choice() {
    local title="$1"
    shift
    local -a items=("$@")
    local i
    printf '\n%s:\n' "$title"
    for ((i=0; i<${#items[@]}; i++)); do
        printf '  [%d] %s\n' "$((i+1))" "${items[i]}"
    done
    local answer
    read -rp $'Choice > ' answer
    printf '%s' "$answer"
}

# --- Package manager dispatch ----------------------------------------------

# Detect the system's package manager. Echoes one of:
# brew | apt | dnf | yum | pacman | zypper | apk | unknown
detect_package_manager() {
    if [[ "$(uname)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
        printf 'brew'
        return
    fi
    for pm in apt-get dnf yum pacman zypper apk; do
        if command -v "$pm" >/dev/null 2>&1; then
            case "$pm" in
                apt-get) printf 'apt'   ;;
                dnf)     printf 'dnf'   ;;
                yum)     printf 'yum'   ;;
                pacman)  printf 'pacman';;
                zypper)  printf 'zypper';;
                apk)     printf 'apk'   ;;
            esac
            return
        fi
    done
    printf 'unknown'
}

# Install a package. The mapping argument is a space-separated list of
# "pm=package" pairs. The first matching pair for the detected package
# manager wins. Fallback to the second positional arg (a single package
# name) if no mapping matches.
#
# Usage:
#   install_package "apt=netcat-openbsd dnf=nmap-ncat pacman=openbsd-netcat brew=netcat" "nc"
install_package() {
    local mapping="$1"
    local fallback="${2:-}"
    local pm
    pm=$(detect_package_manager)
    if [[ "$pm" == "unknown" ]]; then
        log_error "No supported package manager detected. Install manually."
        return 1
    fi

    local pkg=""
    local pair
    for pair in $mapping; do
        if [[ "${pair%%=*}" == "$pm" ]]; then
            pkg="${pair#*=}"
            break
        fi
    done
    pkg="${pkg:-$fallback}"
    if [[ -z "$pkg" ]]; then
        log_error "No package name known for $pm."
        return 1
    fi

    log_step "Installing ${pkg} via ${pm}"
    case "$pm" in
        apt)    sudo apt-get update && sudo apt-get install -y "$pkg" ;;
        dnf)    sudo dnf install -y "$pkg" ;;
        yum)    sudo yum install -y "$pkg" ;;
        pacman) sudo pacman -Sy --noconfirm "$pkg" ;;
        zypper) sudo zypper --non-interactive install "$pkg" ;;
        apk)    sudo apk add "$pkg" ;;
        brew)   brew install "$pkg" ;;
    esac
}

# Ensure a binary is on PATH. If missing, attempt to install it. Returns
# 0 if the binary is available afterwards, 1 otherwise.
#
# Usage:
#   ensure_command nmap "apt=nmap dnf=nmap pacman=nmap brew=nmap" || return 0
ensure_command() {
    local cmd="$1"
    local mapping="${2:-}"
    local fallback="${3:-$cmd}"

    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    fi

    log_warn "${cmd} not found. Attempting to install..."
    if ! install_package "$mapping" "$fallback"; then
        log_error "Failed to install ${cmd}."
        return 1
    fi
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "${cmd} still not available after install attempt."
        return 1
    fi
    log_success "${cmd} installed."
}

# Pause and wait for the user before returning to the menu.
press_enter_to_continue() {
    printf '\n%b\n' "${DIM}Press Enter to continue...${RESET}"
    read -r
}
