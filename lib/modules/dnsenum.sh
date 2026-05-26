#!/usr/bin/env bash
# lib/modules/dnsenum.sh — Dnsenum module.

if [[ -n "${FEEDYOURSPIDER_MOD_DNSENUM_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_MOD_DNSENUM_LOADED=1

dnsenum_run() {
    ensure_command dnsenum \
        "apt=dnsenum dnf=dnsenum yum=dnsenum pacman=dnsenum zypper=dnsenum apk=dnsenum brew=dnsenum" \
        "dnsenum" || return 0

    log_step "Launching Dnsenum"
    local outdir outbase domain
    outdir=$(fys_outdir dnsenum)
    domain=$(prompt_value "Domain")
    if [[ -z "$domain" ]]; then
        log_error "No domain provided."
        return 0
    fi
    outbase="${outdir}/enum_${domain}_$(fys_timestamp).txt"

    log_step "Enumerating DNS for ${domain}"
    log_info "Saving to ${outbase}"
    dnsenum "$domain" | tee "$outbase"
}
