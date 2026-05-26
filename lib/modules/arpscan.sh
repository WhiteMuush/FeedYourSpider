#!/usr/bin/env bash
# lib/modules/arpscan.sh — Arp-scan module.

if [[ -n "${FEEDYOURSPIDER_MOD_ARPSCAN_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_MOD_ARPSCAN_LOADED=1

arpscan_run() {
    ensure_command arp-scan \
        "apt=arp-scan dnf=arp-scan yum=arp-scan pacman=arp-scan zypper=arp-scan apk=arp-scan brew=arp-scan" \
        "arp-scan" || return 0

    log_step "Launching Arp-scan"
    local outdir
    outdir=$(fys_outdir arpscan)

    local choice
    choice=$(prompt_choice "Arp-scan modes" \
        "Scan local network" \
        "Scan specific range (CIDR)" \
        "Custom args")

    case "$choice" in
        1)
            local outbase
            outbase="${outdir}/localnet_$(fys_timestamp).txt"
            log_step "Scanning local network, saving to ${outbase}"
            sudo arp-scan -l | tee "$outbase"
            ;;
        2)
            local range outbase
            range=$(prompt_value "Network range (CIDR, e.g. 192.168.1.0/24)")
            outbase="${outdir}/scan_${range//\//_}_$(fys_timestamp).txt"
            log_step "Scanning ${range}, saving to ${outbase}"
            sudo arp-scan "$range" | tee "$outbase"
            ;;
        3)
            local custom_args
            custom_args=$(prompt_value "Custom arp-scan args")
            if [[ -z "$custom_args" ]]; then
                log_error "No custom args provided."
                return 0
            fi
            local -a user_args
            read -ra user_args <<<"$custom_args"
            log_step "Running: sudo arp-scan ${user_args[*]}"
            sudo arp-scan "${user_args[@]}"
            ;;
        *) log_error "Invalid choice."; return 0 ;;
    esac
}
