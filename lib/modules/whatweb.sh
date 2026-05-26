#!/usr/bin/env bash
# lib/modules/whatweb.sh — WhatWeb module.

if [[ -n "${FEEDYOURSPIDER_MOD_WHATWEB_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_MOD_WHATWEB_LOADED=1

whatweb_run() {
    ensure_command whatweb \
        "apt=whatweb dnf=whatweb yum=whatweb pacman=whatweb zypper=whatweb apk=whatweb brew=whatweb" \
        "whatweb" || return 0

    log_step "Launching Whatweb"
    local outdir
    outdir=$(fys_outdir whatweb)

    local choice
    choice=$(prompt_choice "Whatweb modes" \
        "Identify URL (verbose)" \
        "Identify URL (quiet)" \
        "Identify URL (all plugins)" \
        "Custom args")

    case "$choice" in
        1)
            local url outbase
            url=$(prompt_value "URL")
            outbase="${outdir}/identify_$(fys_timestamp).txt"
            log_step "Identifying ${url}"
            whatweb -v "$url" | tee "$outbase"
            ;;
        2)
            local url outbase
            url=$(prompt_value "URL")
            outbase="${outdir}/identify_$(fys_timestamp).txt"
            log_step "Identifying ${url}"
            whatweb -q "$url" | tee "$outbase"
            ;;
        3)
            local url outbase
            url=$(prompt_value "URL")
            outbase="${outdir}/identify_$(fys_timestamp).txt"
            log_step "Identifying ${url} with all plugins"
            whatweb -a 4 "$url" | tee "$outbase"
            ;;
        4)
            local custom_args
            custom_args=$(prompt_value "Custom whatweb args")
            if [[ -z "$custom_args" ]]; then
                log_error "No custom args provided."
                return 0
            fi
            local -a user_args
            read -ra user_args <<<"$custom_args"
            log_step "Running: whatweb ${user_args[*]}"
            whatweb "${user_args[@]}"
            ;;
        *) log_error "Invalid choice."; return 0 ;;
    esac
}
