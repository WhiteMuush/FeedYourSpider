#!/usr/bin/env bash
# lib/modules/masscan.sh — Masscan module.

if [[ -n "${FEEDYOURSPIDER_MOD_MASSCAN_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_MOD_MASSCAN_LOADED=1

masscan_run() {
    ensure_command masscan \
        "apt=masscan dnf=masscan yum=masscan pacman=masscan zypper=masscan apk=masscan brew=masscan" \
        "masscan" || return 0

    log_step "Launching Masscan"
    local outdir
    outdir=$(fys_outdir masscan)

    local target ports outbase
    target=$(prompt_value "Target (IP or CIDR)")
    ports=$(prompt_value "Ports (e.g. 80,443,1-1000)")
    outbase="${outdir}/masscan_${target//\//_}_$(fys_timestamp)"

    log_step "Running masscan on ${target} for ports ${ports}"
    log_info "Saving to ${outbase}.gnmap"
    sudo masscan "$target" -p "$ports" -oG "${outbase}.gnmap" --rate 5000
}
