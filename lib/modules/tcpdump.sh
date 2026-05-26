#!/usr/bin/env bash
# lib/modules/tcpdump.sh — Tcpdump module.

if [[ -n "${FEEDYOURSPIDER_MOD_TCPDUMP_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_MOD_TCPDUMP_LOADED=1

tcpdump_run() {
    ensure_command tcpdump \
        "apt=tcpdump dnf=tcpdump yum=tcpdump pacman=tcpdump zypper=tcpdump apk=tcpdump brew=tcpdump" \
        "tcpdump" || return 0

    log_step "Launching Tcpdump"
    local outdir outbase
    outdir=$(fys_outdir tcpdump)
    outbase="${outdir}/capture_$(fys_timestamp)"

    local choice
    choice=$(prompt_choice "Tcpdump modes" \
        "Capture on interface" \
        "Capture specific port" \
        "Capture specific host" \
        "Custom filter")

    local -a tcpdump_args
    case "$choice" in
        1)
            local iface
            iface=$(prompt_value "Interface (or 'any')" "any")
            tcpdump_args=(-i "$iface" -w "${outbase}.pcap")
            ;;
        2)
            local port
            port=$(prompt_value "Port")
            tcpdump_args=(-i any "port $port" -w "${outbase}.pcap")
            ;;
        3)
            local host
            host=$(prompt_value "Host IP")
            tcpdump_args=(-i any "host $host" -w "${outbase}.pcap")
            ;;
        4)
            local filter
            filter=$(prompt_value "Filter expression")
            tcpdump_args=(-i any "$filter" -w "${outbase}.pcap")
            ;;
        *) log_error "Invalid choice."; return 0 ;;
    esac

    log_info "Saving to ${outbase}.pcap"
    log_step "Running: sudo tcpdump ${tcpdump_args[*]}"
    log_info "Press Ctrl+C to stop"
    sudo tcpdump "${tcpdump_args[@]}"
}
