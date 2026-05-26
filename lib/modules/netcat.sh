#!/usr/bin/env bash
# lib/modules/netcat.sh — Netcat (nc) module.

if [[ -n "${FEEDYOURSPIDER_MOD_NETCAT_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_MOD_NETCAT_LOADED=1

# Resolve the netcat binary path. Supports both `nc` and `netcat`.
_netcat_cmd() {
    command -v nc 2>/dev/null || command -v netcat 2>/dev/null
}

netcat_run() {
    if [[ -z "$(_netcat_cmd)" ]]; then
        ensure_command nc \
            "apt=netcat-openbsd dnf=nmap-ncat yum=nmap-ncat pacman=openbsd-netcat zypper=netcat-openbsd apk=netcat-openbsd brew=netcat" \
            "netcat" || return 0
    fi
    local nc_cmd
    nc_cmd=$(_netcat_cmd)
    if [[ -z "$nc_cmd" ]]; then
        log_error "netcat (nc) is not available after install attempt."
        return 0
    fi

    log_step "Launching Netcat"
    local outdir
    outdir=$(fys_outdir netcat)

    local choice
    choice=$(prompt_choice "Netcat actions" \
        "Connect to host (client)" \
        "Listen (server)" \
        "File transfer (send/receive)" \
        "Banner grab" \
        "Custom args")

    case "$choice" in
        1) _netcat_connect  "$nc_cmd" "$outdir" ;;
        2) _netcat_listen   "$nc_cmd" "$outdir" ;;
        3) _netcat_transfer "$nc_cmd" "$outdir" ;;
        4) _netcat_banner   "$nc_cmd" ;;
        5) _netcat_custom   "$nc_cmd" ;;
        *) log_error "Invalid choice." ;;
    esac
}

_netcat_connect() {
    local nc_cmd="$1" outdir="$2"
    local target port proto
    target=$(prompt_value "Target (ip/host)")
    port=$(prompt_value "Port")
    proto=$(prompt_value "Protocol [tcp/udp]" "tcp")

    local -a nc_args
    [[ "$proto" == "udp" ]] && nc_args+=(-u)
    nc_args+=(-v -w 5 "$target" "$port")

    local outbase
    outbase="${outdir}/connect_${target}_${port}_$(fys_timestamp).log"
    log_info "Saving session to ${outbase}"
    log_step "Running: ${nc_cmd} ${nc_args[*]}"
    "$nc_cmd" "${nc_args[@]}" |& tee "$outbase"
}

_netcat_listen() {
    local nc_cmd="$1" outdir="$2"
    local port proto
    port=$(prompt_value "Listen port")
    proto=$(prompt_value "Protocol [tcp/udp]" "tcp")

    local outbase
    outbase="${outdir}/listen_${port}_$(fys_timestamp).log"
    log_info "Saving incoming data to ${outbase}"

    if [[ "$proto" == "udp" ]]; then
        log_step "Listening UDP on port ${port}"
        "$nc_cmd" -u -l "$port" |& tee "$outbase"
    else
        log_step "Listening TCP on port ${port}"
        if "$nc_cmd" -h 2>&1 | grep -qi -- "-p"; then
            "$nc_cmd" -l -p "$port" |& tee "$outbase"
        else
            "$nc_cmd" -l "$port" |& tee "$outbase"
        fi
    fi
}

_netcat_transfer() {
    local nc_cmd="$1" outdir="$2"
    local choice
    choice=$(prompt_choice "File transfer" \
        "Send file to remote (client)" \
        "Receive file (server/listen)")

    case "$choice" in
        1)
            local target port filepath outbase
            target=$(prompt_value "Target (ip/host)")
            port=$(prompt_value "Port")
            filepath=$(prompt_value "Path to file to send")
            if [[ ! -f "$filepath" ]]; then
                log_error "File not found: ${filepath}"
                return 0
            fi
            outbase="${outdir}/send_$(basename "$filepath")_${target}_${port}_$(fys_timestamp).log"
            log_step "Sending ${filepath} -> ${target}:${port}"
            "$nc_cmd" "$target" "$port" < "$filepath" |& tee "$outbase"
            ;;
        2)
            local port outname outpath
            port=$(prompt_value "Listen port")
            outname=$(prompt_value "Output filename (optional)")
            outpath="${outdir}/${outname:-received_$(fys_timestamp)}"
            log_step "Listening on port ${port}, saving to ${outpath}"
            if "$nc_cmd" -h 2>&1 | grep -qi -- "-p"; then
                "$nc_cmd" -l -p "$port" > "$outpath"
            else
                "$nc_cmd" -l "$port" > "$outpath"
            fi
            log_info "Saved to ${outpath}"
            ;;
        *) log_error "Invalid choice." ;;
    esac
}

_netcat_banner() {
    local nc_cmd="$1"
    local target port proto
    target=$(prompt_value "Target (ip/host)")
    port=$(prompt_value "Port")
    proto=$(prompt_value "Protocol [tcp/udp]" "tcp")
    log_step "Banner grab ${target}:${port} (${proto})"
    if [[ "$proto" == "udp" ]]; then
        "$nc_cmd" -u -v -w 3 "$target" "$port"
    else
        printf "HEAD / HTTP/1.0\r\n\r\n" | "$nc_cmd" -v -w 3 "$target" "$port" \
            || "$nc_cmd" -v -w 3 "$target" "$port"
    fi
}

_netcat_custom() {
    local nc_cmd="$1"
    local custom_args
    custom_args=$(prompt_value "Custom nc args (e.g. -v -w 3 target port)")
    if [[ -z "$custom_args" ]]; then
        log_error "No custom args provided."
        return 0
    fi
    local -a user_args
    read -ra user_args <<<"$custom_args"
    log_step "Running: ${nc_cmd} ${user_args[*]}"
    "$nc_cmd" "${user_args[@]}"
}
