#!/usr/bin/env bash
# lib/modules/hping3.sh — Hping3 module.

if [[ -n "${FEEDYOURSPIDER_MOD_HPING3_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_MOD_HPING3_LOADED=1

hping3_run() {
    ensure_command hping3 \
        "apt=hping3 dnf=hping3 yum=hping3 pacman=hping zypper=hping3 apk=hping3 brew=hping" \
        "hping3" || return 0

    log_step "Launching Hping3"

    local choice
    choice=$(prompt_choice "Hping3 modes" \
        "TCP SYN scan" \
        "UDP ping" \
        "ICMP echo" \
        "Custom args")

    case "$choice" in
        1)
            local target port
            target=$(prompt_value "Target")
            port=$(prompt_value "Port")
            log_step "Running TCP SYN scan on ${target}:${port}"
            sudo hping3 -S --dport "$port" "$target"
            ;;
        2)
            local target
            target=$(prompt_value "Target")
            log_step "Running UDP ping to ${target}"
            sudo hping3 --udp "$target"
            ;;
        3)
            local target
            target=$(prompt_value "Target")
            log_step "Running ICMP echo to ${target}"
            sudo hping3 -1 "$target"
            ;;
        4)
            local custom_args
            custom_args=$(prompt_value "Custom hping3 args")
            if [[ -z "$custom_args" ]]; then
                log_error "No custom args provided."
                return 0
            fi
            local -a user_args
            read -ra user_args <<<"$custom_args"
            log_step "Running: sudo hping3 ${user_args[*]}"
            sudo hping3 "${user_args[@]}"
            ;;
        *) log_error "Invalid choice."; return 0 ;;
    esac
}
