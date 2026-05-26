#!/usr/bin/env bash
# lib/modules/nmap.sh — Nmap module.

if [[ -n "${FEEDYOURSPIDER_MOD_NMAP_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_MOD_NMAP_LOADED=1

nmap_run() {
    ensure_command nmap "apt=nmap dnf=nmap yum=nmap pacman=nmap zypper=nmap apk=nmap brew=nmap" "nmap" || return 0

    log_step "Launching Nmap"
    local target
    target=$(prompt_value "Target (ip/host or CIDR)")
    if [[ -z "$target" ]]; then
        log_error "No target provided."
        return 0
    fi

    local outdir outbase safe_target
    outdir=$(fys_outdir nmap)
    safe_target=$(fys_safe_name "$target")
    outbase="${outdir}/scan_${safe_target}_$(fys_timestamp)"

    local choice
    choice=$(prompt_choice "Select scan type" \
        "Quick (top ports)" \
        "Service/version (-sV + default scripts)" \
        "Aggressive (-A)" \
        "All ports (-p-)" \
        "SYN stealth (-sS)" \
        "Custom args")

    local -a nmap_args
    case "$choice" in
        1) nmap_args=(-T4 --top-ports 100 -oA "$outbase") ;;
        2) nmap_args=(-sV -sC -T4 -oA "$outbase") ;;
        3) nmap_args=(-A -T4 -oA "$outbase") ;;
        4) nmap_args=(-p- -T4 -oA "$outbase") ;;
        5) nmap_args=(-sS -T4 -oA "$outbase") ;;
        6)
            local custom_args
            custom_args=$(prompt_value "Custom nmap args (e.g. -p 1-65535 -sV)")
            if [[ -z "$custom_args" ]]; then
                log_error "No custom args provided. Aborting."
                return 0
            fi
            local -a user_args
            read -ra user_args <<<"$custom_args"
            nmap_args=("${user_args[@]}" -oA "$outbase")
            ;;
        *)
            log_error "Invalid choice."
            return 0
            ;;
    esac

    log_info "Saving results to ${outbase}.{nmap,gnmap,xml}"

    local need_sudo=0 a
    for a in "${nmap_args[@]}"; do
        case "$a" in
            -sS|-A|-p-) need_sudo=1; break ;;
        esac
    done

    log_step "Running: nmap ${nmap_args[*]} ${target}"
    if (( need_sudo )); then
        log_info "Using sudo for this scan (you may be prompted for your password)"
        sudo nmap "${nmap_args[@]}" "$target"
    else
        nmap "${nmap_args[@]}" "$target"
    fi
}
