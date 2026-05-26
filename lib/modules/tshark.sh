#!/usr/bin/env bash
# lib/modules/tshark.sh — Wireshark (tshark) module.

if [[ -n "${FEEDYOURSPIDER_MOD_TSHARK_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_MOD_TSHARK_LOADED=1

tshark_run() {
    ensure_command tshark \
        "apt=tshark dnf=wireshark yum=wireshark pacman=wireshark-cli zypper=wireshark apk=tshark brew=wireshark" \
        "tshark" || return 0

    log_step "Launching Wireshark (tshark)"
    local outdir
    outdir=$(fys_outdir tshark)

    local choice
    choice=$(prompt_choice "Tshark modes" \
        "Live capture on interface" \
        "Read pcap file" \
        "Packet statistics")

    case "$choice" in
        1)
            local iface outbase
            iface=$(prompt_value "Interface (or 'any')" "any")
            outbase="${outdir}/capture_$(fys_timestamp).pcap"
            log_step "Capturing on ${iface}, saving to ${outbase}"
            log_info "Press Ctrl+C to stop"
            sudo tshark -i "$iface" -w "$outbase"
            ;;
        2)
            local pcapfile
            pcapfile=$(prompt_value "Path to pcap file")
            if [[ ! -f "$pcapfile" ]]; then
                log_error "File not found: ${pcapfile}"
                return 0
            fi
            tshark -r "$pcapfile" | head -50
            ;;
        3)
            local pcapfile
            pcapfile=$(prompt_value "Path to pcap file")
            if [[ ! -f "$pcapfile" ]]; then
                log_error "File not found: ${pcapfile}"
                return 0
            fi
            log_step "Top protocols:"
            tshark -r "$pcapfile" -q -z io,phs
            ;;
        *) log_error "Invalid choice."; return 0 ;;
    esac
}
