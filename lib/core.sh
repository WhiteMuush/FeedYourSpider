#!/usr/bin/env bash
# lib/core.sh — Constants, colors, and shared globals.

if [[ -n "${FEEDYOURSPIDER_CORE_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_CORE_LOADED=1

readonly FEEDYOURSPIDER_VERSION="1.1.0"

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
