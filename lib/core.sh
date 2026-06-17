#!/usr/bin/env bash
# lib/core.sh — Constants, colors, and shared globals.

if [[ -n "${FEEDYOURSPIDER_CORE_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_CORE_LOADED=1

readonly FEEDYOURSPIDER_VERSION="1.1.0"

# Single source of truth for the tool menu. Order defines the menu numbers
# (1-based). Each entry is "Label:function". Both the menu renderer
# (lib/ui.sh) and the dispatcher (feedyourspider.sh) derive from this, so
# adding a tool means editing this list only.
FEEDYOURSPIDER_TOOLS=(
    "Nmap:nmap_run"
    "Netcat:netcat_run"
    "Tcpdump:tcpdump_run"
    "Wireshark (tshark):tshark_run"
    "Hping3:hping3_run"
    "Arp-scan:arpscan_run"
    "Masscan:masscan_run"
    "Nikto:nikto_run"
    "Dnsenum:dnsenum_run"
    "Whatweb:whatweb_run"
)
readonly FEEDYOURSPIDER_TOOLS

# Output base directory for per-tool result folders.
FEEDYOURSPIDER_OUTPUT_ROOT="${FEEDYOURSPIDER_OUTPUT_ROOT:-${HOME}}"

# TTY-aware color setup. When stdout is not a terminal (pipe, redirect,
# CI log), color sequences are emitted as empty strings so the output
# stays clean.
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    RESET="$(tput sgr0)"
    BOLD="$(tput bold)"
    DIM="$(tput dim)"
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    BLUE="$(tput setaf 4)"
    MAGENTA="$(tput setaf 5)"
    CYAN="$(tput setaf 6)"
    BRIGHT_RED="$(tput setaf 9)"
    BRIGHT_GREEN="$(tput setaf 10)"
    BRIGHT_BLUE="$(tput setaf 12)"
    BRIGHT_MAGENTA="$(tput setaf 13)"
    BRIGHT_CYAN="$(tput setaf 14)"
else
    RESET=""
    BOLD=""
    DIM=""
    RED=""
    GREEN=""
    BLUE=""
    MAGENTA=""
    CYAN=""
    BRIGHT_RED=""
    BRIGHT_GREEN=""
    BRIGHT_BLUE=""
    BRIGHT_MAGENTA=""
    BRIGHT_CYAN=""
fi

readonly RESET BOLD DIM
readonly RED GREEN BLUE MAGENTA CYAN
readonly BRIGHT_RED BRIGHT_GREEN BRIGHT_BLUE BRIGHT_MAGENTA BRIGHT_CYAN

# Build a per-tool, timestamped output directory under FEEDYOURSPIDER_OUTPUT_ROOT.
# Usage: dir=$(fys_outdir nmap)
fys_outdir() {
    local tool="$1"
    local dir="${FEEDYOURSPIDER_OUTPUT_ROOT}/feedyourspider_${tool}"
    mkdir -p "$dir"
    printf '%s' "$dir"
}

# Current timestamp suitable for filenames: YYYYMMDD_HHMMSS.
fys_timestamp() {
    date +%Y%m%d_%H%M%S
}

# Sanitize an arbitrary string for use as a filename component.
fys_safe_name() {
    printf '%s' "$1" | sed 's/[^A-Za-z0-9._-]/_/g'
}

# --- Input validation -------------------------------------------------------
# Each helper returns 0 when the value is well-formed, 1 otherwise. They are
# silent; callers decide how to report failure.

# A single TCP/UDP port (1-65535).
fys_is_port() {
    local p="$1"
    [[ "$p" =~ ^[0-9]+$ ]] && (( p >= 1 && p <= 65535 ))
}

# A port specification accepted by nmap/masscan: comma lists and ranges of
# ports, e.g. "80", "1-1000", "22,80,443", "1-65535". Empty is rejected.
fys_is_port_spec() {
    local spec="$1"
    [[ -n "$spec" ]] || return 1
    [[ "$spec" =~ ^[0-9]+(-[0-9]+)?(,[0-9]+(-[0-9]+)?)*$ ]]
}

# A dotted-quad IPv4 address with each octet in 0-255.
fys_is_ipv4() {
    local ip="$1" o
    [[ "$ip" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]] || return 1
    for o in "${BASH_REMATCH[@]:1}"; do
        (( o <= 255 )) || return 1
    done
}

# A hostname label set per RFC 1123 (letters, digits, hyphens, dots).
fys_is_hostname() {
    local h="$1"
    (( ${#h} <= 253 )) || return 1
    [[ "$h" =~ ^([A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)*[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$ ]]
}

# A target that is acceptable as a host: IPv4 or hostname.
fys_is_host() {
    fys_is_ipv4 "$1" || fys_is_hostname "$1"
}

# IPv4 CIDR notation, e.g. 192.168.1.0/24. Prefix must be 0-32.
fys_is_cidr() {
    local cidr="$1"
    [[ "$cidr" == */* ]] || return 1
    local addr="${cidr%/*}" prefix="${cidr#*/}"
    [[ "$prefix" =~ ^[0-9]+$ ]] && (( prefix <= 32 )) || return 1
    fys_is_ipv4 "$addr"
}

# A target accepted by scanners that take a host or a CIDR range.
fys_is_host_or_cidr() {
    fys_is_host "$1" || fys_is_cidr "$1"
}
