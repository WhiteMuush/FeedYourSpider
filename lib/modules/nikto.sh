#!/usr/bin/env bash
# lib/modules/nikto.sh — Nikto module.

if [[ -n "${FEEDYOURSPIDER_MOD_NIKTO_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_MOD_NIKTO_LOADED=1

nikto_run() {
    ensure_command nikto \
        "apt=nikto dnf=nikto yum=nikto pacman=nikto zypper=nikto apk=nikto brew=nikto" \
        "nikto" || return 0

    log_step "Launching Nikto"
    local outdir
    outdir=$(fys_outdir nikto)

    local choice
    choice=$(prompt_choice "Nikto modes" \
        "Scan URL" \
        "Scan host:port" \
        "Custom args")

    case "$choice" in
        1)
            local url outbase
            url=$(prompt_value "URL (e.g. http://example.com)")
            outbase="${outdir}/scan_$(fys_timestamp).txt"
            log_step "Scanning ${url}, saving to ${outbase}"
            nikto -url "$url" -o "$outbase"
            ;;
        2)
            local host port outbase
            host=$(prompt_valid "Host" fys_is_host) || return 0
            port=$(prompt_valid "Port" fys_is_port "80") || return 0
            outbase="${outdir}/scan_${host}_${port}_$(fys_timestamp).txt"
            log_step "Scanning ${host}:${port}, saving to ${outbase}"
            nikto -h "$host" -p "$port" -o "$outbase"
            ;;
        3) run_custom_args nikto "Custom nikto args" ;;
        *) log_error "Invalid choice."; return 0 ;;
    esac
}
