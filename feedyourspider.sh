#!/usr/bin/env bash
# feedyourspider.sh — Interactive launcher for common network tools.
# Thin orchestrator: loads lib/ and dispatches menu choices to modules.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"
MOD_DIR="${LIB_DIR}/modules"

# shellcheck source=lib/core.sh
source "${LIB_DIR}/core.sh"
# shellcheck source=lib/installer.sh
source "${LIB_DIR}/installer.sh"
# shellcheck source=lib/ui.sh
source "${LIB_DIR}/ui.sh"

# shellcheck source=lib/modules/nmap.sh
source "${MOD_DIR}/nmap.sh"
# shellcheck source=lib/modules/netcat.sh
source "${MOD_DIR}/netcat.sh"
# shellcheck source=lib/modules/tcpdump.sh
source "${MOD_DIR}/tcpdump.sh"
# shellcheck source=lib/modules/tshark.sh
source "${MOD_DIR}/tshark.sh"
# shellcheck source=lib/modules/hping3.sh
source "${MOD_DIR}/hping3.sh"
# shellcheck source=lib/modules/arpscan.sh
source "${MOD_DIR}/arpscan.sh"
# shellcheck source=lib/modules/masscan.sh
source "${MOD_DIR}/masscan.sh"
# shellcheck source=lib/modules/nikto.sh
source "${MOD_DIR}/nikto.sh"
# shellcheck source=lib/modules/dnsenum.sh
source "${MOD_DIR}/dnsenum.sh"
# shellcheck source=lib/modules/whatweb.sh
source "${MOD_DIR}/whatweb.sh"

dispatch_choice() {
    case "$1" in
        1)  nmap_run     ;;
        2)  netcat_run   ;;
        3)  tcpdump_run  ;;
        4)  tshark_run   ;;
        5)  hping3_run   ;;
        6)  arpscan_run  ;;
        7)  masscan_run  ;;
        8)  nikto_run    ;;
        9)  dnsenum_run  ;;
        10) whatweb_run  ;;
        0)
            log_step "Exiting..."
            exit 0
            ;;
        *)
            log_error "Invalid choice. Please try again."
            ;;
    esac
}

main_loop() {
    display_title_middle_screen
    sleep 2

    local choice
    while true; do
        clear
        display_banner_with_menu
        echo -ne "    ${BOLD}${BRIGHT_RED}FEED YOUR SPIDER: ${RESET}"
        read -r choice
        dispatch_choice "$choice"
        if [[ "$choice" != "0" ]]; then
            press_enter_to_continue
        fi
    done
}

main_loop
