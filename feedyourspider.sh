#!/bin/bash

# ============================================================================
# COLOR DEFINITIONS
# ============================================================================
readonly RESET="$(tput sgr0)"
readonly BOLD="$(tput bold)"
readonly DIM="$(tput dim)"

# Standard colors
readonly RED="$(tput setaf 1)"
readonly GREEN="$(tput setaf 2)"
readonly BLUE="$(tput setaf 4)"
readonly MAGENTA="$(tput setaf 5)"
readonly CYAN="$(tput setaf 6)"

# Bright colors
readonly BRIGHT_RED="$(tput setaf 9)"
readonly BRIGHT_GREEN="$(tput setaf 10)"
readonly BRIGHT_BLUE="$(tput setaf 12)"
readonly BRIGHT_MAGENTA="$(tput setaf 13)"
readonly BRIGHT_CYAN="$(tput setaf 14)"

# ============================================================================
# ASCII ART BANNER
# ============================================================================
readonly ASCII_ART=$(cat <<'ASCII'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠤⠤⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⡼⠟⠓⠒⠂⠀⢀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⠀⠀⠀⠀⠀⣐⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡤⠖⠋⠁⠀⠀⠀⠀⠀⢀⠔⠃⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣮⡅⠀⠀⠀⠀⢠⡁⠀⠀⠀⠀⠀⣠⣶⡼⠛⠁⠀⠀⠀⠀⠀⠀⠀⢀⡴⠃⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣏⡀⠀⠀⠀⠘⠀⠀⠀⠀⠀⣦⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⡇⠀⠀⢌⠁⠀⠀⠀⠀⣰⠏⠀⠀⠀⠀⠀⠀⠀⠀⢀⠴⠊⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⡀⠀⠀⠀⠀⣿⠀⠀⠎⠀⠀⠀⠀⢰⡏⠀⠀⠀⠀⠀⠀⠀⢀⣠⣧⣤⠤⠤⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠈⠻⣦⠀⠀⠀⢸⣧⠀⠁⠀⠀⠀⢀⣿⠀⠀⠀⠀⣀⣤⡶⠚⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢦⡀⠀⠘⣻⢀⠄⠀⠀⠀⢸⠇⢐⣆⡾⠟⠉⠀⠀⠀⠀⠀⠀⠀⢀⠔⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣄⣄⣾⠶⢆⣀⣀⣀⣿⣦⣤⣿⣟⣖⣜⣅⣰⢏⣠⢟⠉⠀⠀⠀⠀⠀⠀⠀⢀⠤⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⢇⠜⠉⠒⣿⣿⡿⠟⢻⣿⣿⣿⣿⣿⣿⣜⣵⠟⠁⠀⠀⠀⠀⠀⠀⢀⠠⠠⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⡪⠁⠀⠀⠀⣰⣿⣃⣤⣤⣾⣿⣿⣿⡿⢿⣿⣿⢿⠆⠀⠀⠀⠀⠀⠛⠑⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⡾⠁⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⢿⢳⣿⣿⠁⠈⠻⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⡾⠁⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⡏⣦⣿⡿⠁⠀⠀⠀⠱⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⠃⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣷⣿⠟⢁⠀⠀⠀⠀⠀⠈⠣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡜⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⠿⠿⢿⣿⡟⠁⠀⠈⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⣻⠁⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠔⠁⠀⠀⠀⠀⠀⠀⠀⢠⠗⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡌⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
ASCII
)

# ============================================================================
# MENU ITEMS
# ============================================================================
generate_menu() {
    local -a menu_lines=(
        ""
        "${BOLD}${BRIGHT_RED}____ ____ ____ ___     _   _ ____ _  _ ____    ____ ___  _ ___  ____ ____ ${RESET}"
        "${BOLD}${BRIGHT_RED}|___ |___ |___ |  \\     \\_/  |  | |  | |__/    [__  |__] | |  \\ |___ |__/ ${RESET}"
        "${BOLD}${BRIGHT_RED}|    |___ |___ |__/      |   |__| |__| |  \\    ___] |    | |__/ |___ |  \\ ${RESET}"
        "${BOLD}${BRIGHT_RED}                                                                          ${RESET}"
        ""
        "${BRIGHT_MAGENTA}🕸️ Creator: \e]8;;https://github.com/WhiteMuush\aMelvin PETIT\e]8;;\a   ${BRIGHT_RED}${BOLD}Use only on authorized targets${RESET}          ${DIM}v0.0.1${RESET}"
        ""
        ""
        ""
        "${BOLD}${BRIGHT_MAGENTA}${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${DIM}Spider is hungry... Feed it with machine data!${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[1]${RESET} Nmap"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[2]${RESET} Netcat"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[3]${RESET} Tcpdump"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[4]${RESET} Wireshark (tshark)"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[5]${RESET} Hping3"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[6]${RESET} Arp-scan"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[7]${RESET} Masscan"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[8]${RESET} nikto"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[9]${RESET} Dnsenum"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[9]${RESET} Whatweb"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[0]${RESET}Exit"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}"
        ""
        ""
    )
    
    printf '%s\n' "${menu_lines[@]}"
}

# ============================================================================
# INFORMATION PANEL
# ============================================================================
readonly INFO_PANEL=(
    ""
    "${BOLD}${BRIGHT_RED}____ ____ ____ ___     _   _ ____ _  _ ____    ____ ___  _ ___  ____ ____ ${RESET}"
    "${BOLD}${BRIGHT_RED}|___ |___ |___ |  \\     \\_/  |  | |  | |__/    [__  |__] | |  \\ |___ |__/ ${RESET}"
    "${BOLD}${BRIGHT_RED}|    |___ |___ |__/      |   |__| |__| |  \\    ___] |    | |__/ |___ |  \\ ${RESET}"
    "${BOLD}${BRIGHT_RED}                                                                          ${RESET}"
    ""
    "${BRIGHT_MAGENTA}🕸️ Creator: \e]8;;https://github.com/WhiteMuush\aMelvin PETIT\e]8;;\a   ${BRIGHT_RED}${BOLD}Use only on authorized targets${RESET}          ${DIM}v0.0.1${RESET}"
    ""
)

# Center the INFO_PANEL in the terminal (both vertically and horizontally)
display_title_middle_screen() {
    local cols rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)

    local -a lines=(
        "${INFO_PANEL[1]}"
        "${INFO_PANEL[2]}"
        "${INFO_PANEL[3]}"
        ""
        "BY MELVIN PETIT"
    )
    local h=${#lines[@]}

    strip_esc() {
        sed -E 's/\x1B\[[0-9;?]*[ -/]*[@-~]//g; s/\x1B\][^\a]*\a//g'
    }

    local max_w=0 raw visible_len line
    for line in "${lines[@]}"; do
        raw=$(printf "%s" "$line" | strip_esc)
        visible_len=${#raw}
        (( visible_len > max_w )) && max_w=$visible_len
    done

    local top=$(( (rows - h) / 2 ))
    (( top < 0 )) && top=0
    local left=$(( (cols - max_w) / 2 ))
    (( left < 0 )) && left=0

    printf "\033c"
    for ((i=0; i<top; i++)); do printf "\n"; done

    for line in "${lines[@]}"; do
        printf "%*s%s\n" "$left" "" "$line"
    done
}

# Display ASCII art with menu side-by-side
display_banner_with_menu() {
    local -a ascii_lines menu_lines
    
    IFS=$'\n' read -r -d '' -a ascii_lines <<< "$ASCII_ART" || true
    IFS=$'\n' read -r -d '' -a menu_lines <<< "$(generate_menu)" || true
    
    local ascii_count=${#ascii_lines[@]}
    local menu_count=${#menu_lines[@]}
    local max_lines=$((ascii_count > menu_count ? ascii_count : menu_count))
    
    local max_ascii_width=0
    for line in "${ascii_lines[@]}"; do
        ((${#line} > max_ascii_width)) && max_ascii_width=${#line}
    done
    
    local spacing="    "
    
    for ((i=0; i<max_lines; i++)); do
        local ascii_line="${ascii_lines[i]:-}"
        local menu_line="${menu_lines[i]:-}"
        
        local colored_ascii="${BRIGHT_MAGENTA}${ascii_line}${RESET}"
        local pad=$((max_ascii_width - ${#ascii_line}))
        ((pad < 0)) && pad=0
        
        printf "   %b%*s%s%b\n" \
            "$colored_ascii" \
            "$pad" "" \
            "$spacing" \
            "$menu_line"
    done
    
    echo ""
}


# ============================================================================
# MENU HANDLER
# ============================================================================
handle_menu_choice() {
    local choice=$1
    
    case $choice in
        1)
        # Verify nmap is installed; attempt automated install if missing
        if ! command -v nmap >/dev/null 2>&1; then
            echo -e "${BRIGHT_MAGENTA}nmap not found. Attempting to install...${RESET}"
            if [[ "$(uname)" == "Darwin" ]]; then
                if command -v brew >/dev/null 2>&1; then
                    brew install nmap || { echo -e "${BRIGHT_RED}Failed to install nmap via brew.${RESET}"; return; }
                else
                    echo -e "${BRIGHT_RED}Homebrew not found. Please install Homebrew or nmap manually.${RESET}"
                    return
                fi
            else
                if command -v apt-get >/dev/null 2>&1; then
                    sudo apt-get update && sudo apt-get install -y nmap || { echo -e "${BRIGHT_RED}apt-get install failed.${RESET}"; return; }
                elif command -v dnf >/dev/null 2>&1; then
                    sudo dnf install -y nmap || { echo -e "${BRIGHT_RED}dnf install failed.${RESET}"; return; }
                elif command -v yum >/dev/null 2>&1; then
                    sudo yum install -y nmap || { echo -e "${BRIGHT_RED}yum install failed.${RESET}"; return; }
                elif command -v pacman >/dev/null 2>&1; then
                    sudo pacman -Sy --noconfirm nmap || { echo -e "${BRIGHT_RED}pacman install failed.${RESET}"; return; }
                elif command -v zypper >/dev/null 2>&1; then
                    sudo zypper --non-interactive install nmap || { echo -e "${BRIGHT_RED}zypper install failed.${RESET}"; return; }
                else
                    echo -e "${BRIGHT_RED}Unsupported system or package manager. Please install nmap manually.${RESET}"
                    return
                fi
            fi

            # re-check
            if ! command -v nmap >/dev/null 2>&1; then
                echo -e "${BRIGHT_RED}nmap still not available after install attempt.${RESET}"
                return
            fi

            echo -e "${BRIGHT_MAGENTA}nmap installed successfully.${RESET}"
        fi
            echo -e "\n${BRIGHT_MAGENTA}Launching Nmap${RESET}"

            # Prompt for target
            read -rp $'\nTarget (ip/host or CIDR) > ' target
            if [[ -z $target ]]; then
                echo -e "${BRIGHT_RED}No target provided.${RESET}"
                return
            fi

            # Ensure nmap is available
            if ! command -v nmap >/dev/null 2>&1; then
                echo -e "${BRIGHT_RED}nmap is not installed. Install it (e.g. sudo apt install nmap) and try again.${RESET}"
                return
            fi

            # Prepare output directory and base filename
            outdir="$HOME/feedyourspider_nmap"
            mkdir -p "$outdir"
            safe_target=$(printf "%s" "$target" | sed 's/[^A-Za-z0-9._-]/_/g')
            outbase="$outdir/scan_${safe_target}_$(date +%Y%m%d_%H%M%S)"

            # Let user pick a scan profile
            echo
            echo "Select scan type:"
            echo "  [1] Quick (top ports)"
            echo "  [2] Service/version (-sV + default scripts)"
            echo "  [3] Aggressive (-A)"
            echo "  [4] All ports (-p-)"
            echo "  [5] SYN stealth (-sS)"
            echo "  [6] Custom args"
            read -rp $'Choice [1-6] > ' nmap_choice

            # Build nmap arguments as an array (safer quoting)
            declare -a nmap_args
            case "$nmap_choice" in
                1)
                    nmap_args=(-T4 --top-ports 100 -oA "$outbase")
                    ;;
                2)
                    nmap_args=(-sV -sC -T4 -oA "$outbase")
                    ;;
                3)
                    nmap_args=(-A -T4 -oA "$outbase")
                    ;;
                4)
                    nmap_args=(-p- -T4 -oA "$outbase")
                    ;;
                5)
                    nmap_args=(-sS -T4 -oA "$outbase")
                    ;;
                6)
                    read -rp $'Enter custom nmap args (example: -p 1-65535 -sV) > ' custom_args
                    # split custom args into array safely (simple splitting on spaces)
                    # user should avoid complex quoting; this keeps it straightforward
                    if [[ -z $custom_args ]]; then
                        echo -e "${BRIGHT_RED}No custom args provided. Aborting.${RESET}"
                        return
                    fi
                    # build array: word-split on IFS
                    IFS=' ' read -r -a user_args <<< "$custom_args"
                    nmap_args=("${user_args[@]}" -oA "$outbase")
                    ;;
                *)
                    echo -e "${BRIGHT_RED}Invalid choice.${RESET}"
                    return
                    ;;
            esac

            echo -e "\n${DIM}Saving results to ${outbase}.{nmap,gnmap,xml}${RESET}"

            # Decide if we should use sudo (some scans require root for best results)
            local need_sudo=0
            for a in "${nmap_args[@]}"; do
                case "$a" in
                    -sS|-A|-p-)
                        need_sudo=1
                        break
                        ;;
                esac
            done

            echo -e "${BRIGHT_MAGENTA}Running: nmap ${nmap_args[*]} ${target}${RESET}"
            if (( need_sudo )); then
                echo -e "${DIM}Using sudo for this scan (you may be prompted for your password)${RESET}"
                sudo nmap "${nmap_args[@]}" "$target"
            else
                nmap "${nmap_args[@]}" "$target"
            fi
        ;;
        2)
        # Check/install netcat (nc)
        if ! command -v nc >/dev/null 2>&1 && ! command -v netcat >/dev/null 2>&1; then
            echo -e "${BRIGHT_MAGENTA}netcat not found. Attempting to install...${RESET}"
            if [[ "$(uname)" == "Darwin" ]]; then
                if command -v brew >/dev/null 2>&1; then
                    brew install netcat || { echo -e "${BRIGHT_RED}Failed to install netcat via brew.${RESET}"; return; }
                else
                    echo -e "${BRIGHT_RED}Homebrew not found. Please install Homebrew or netcat manually.${RESET}"
                    return
                fi
            else
                if command -v apt-get >/dev/null 2>&1; then
                    sudo apt-get update && sudo apt-get install -y netcat-openbsd || sudo apt-get install -y netcat || { echo -e "${BRIGHT_RED}apt-get install failed.${RESET}"; return; }
                elif command -v dnf >/dev/null 2>&1; then
                    sudo dnf install -y nmap-ncat || sudo dnf install -y netcat || { echo -e "${BRIGHT_RED}dnf install failed.${RESET}"; return; }
                elif command -v yum >/dev/null 2>&1; then
                    sudo yum install -y nmap-ncat || sudo yum install -y netcat || { echo -e "${BRIGHT_RED}yum install failed.${RESET}"; return; }
                elif command -v pacman >/dev/null 2>&1; then
                    sudo pacman -Sy --noconfirm gnu-netcat || sudo pacman -Sy --noconfirm openbsd-netcat || { echo -e "${BRIGHT_RED}pacman install failed.${RESET}"; return; }
                elif command -v zypper >/dev/null 2>&1; then
                    sudo zypper --non-interactive install netcat-openbsd || sudo zypper --non-interactive install netcat || { echo -e "${BRIGHT_RED}zypper install failed.${RESET}"; return; }
                elif command -v apk >/dev/null 2>&1; then
                    sudo apk add netcat-openbsd || sudo apk add netcat || { echo -e "${BRIGHT_RED}apk install failed.${RESET}"; return; }
                else
                    echo -e "${BRIGHT_RED}Unsupported system or package manager. Please install netcat manually.${RESET}"
                    return
                fi
            fi

            # re-check
            if ! command -v nc >/dev/null 2>&1 && ! command -v netcat >/dev/null 2>&1; then
                echo -e "${BRIGHT_RED}netcat still not available after install attempt.${RESET}"
                return
            fi

            echo -e "${BRIGHT_MAGENTA}netcat installed successfully.${RESET}"
        fi
            echo -e "\n${BRIGHT_MAGENTA}Launching Netcat${RESET}"

            # Ensure nc/netcat is available
            if ! command -v nc >/dev/null 2>&1 && ! command -v netcat >/dev/null 2>&1; then
            echo -e "${BRIGHT_RED}netcat (nc) is not installed. Install it (e.g. sudo apt install netcat-openbsd) and try again.${RESET}"
            return
            fi
            nc_cmd=$(command -v nc || command -v netcat)

            outdir="$HOME/feedyourspider_netcat"
            mkdir -p "$outdir"

            echo
            echo "Netcat actions:"
            echo "  [1] Connect to host (client)"
            echo "  [2] Listen (server)"
            echo "  [3] File transfer (send/receive)"
            echo "  [4] Banner grab"
            echo "  [5] Custom args"
            read -rp $'Choice [1-5] > ' nc_choice

            case "$nc_choice" in
            1)
                read -rp $'Target (ip/host) > ' target
                read -rp $'Port > ' port
                read -rp $'Protocol [tcp/udp] (tcp) > ' proto
                proto=${proto:-tcp}

                declare -a nc_args
                [[ $proto == "udp" ]] && nc_args+=(-u)
                nc_args+=(-v -w 5 "$target" "$port")

                outbase="$outdir/connect_${target}_${port}_$(date +%Y%m%d_%H%M%S).log"
                echo -e "${DIM}Saving session to ${outbase}${RESET}"
                echo -e "${BRIGHT_MAGENTA}Running: $nc_cmd ${nc_args[*]}${RESET}"
                "$nc_cmd" "${nc_args[@]}" |& tee "$outbase"
                ;;
            2)
                read -rp $'Listen port > ' port
                read -rp $'Protocol [tcp/udp] (tcp) > ' proto
                proto=${proto:-tcp}

                outbase="$outdir/listen_${port}_$(date +%Y%m%d_%H%M%S).log"
                echo -e "${DIM}Saving incoming data to ${outbase}${RESET}"

                if [[ $proto == "udp" ]]; then
                echo -e "${BRIGHT_MAGENTA}Listening UDP on port ${port}${RESET}"
                "$nc_cmd" -u -l "$port" |& tee "$outbase"
                else
                echo -e "${BRIGHT_MAGENTA}Listening TCP on port ${port}${RESET}"
                # Try to be portable between flavors (OpenBSD nc uses "-l port", GNU ncat/netcat may expect "-l -p port")
                if "$nc_cmd" -h 2>&1 | grep -qi -- "-p"; then
                    # this branch will work for netcat implementations advertising -p
                    "$nc_cmd" -l -p "$port" |& tee "$outbase"
                else
                    "$nc_cmd" -l "$port" |& tee "$outbase"
                fi
                fi
                ;;
            3)
                echo "File transfer:"
                echo "  [1] Send file to remote (client)"
                echo "  [2] Receive file (server/listen)"
                read -rp $'Choice [1-2] > ' ft_choice
                case "$ft_choice" in
                1)
                    read -rp $'Target (ip/host) > ' target
                    read -rp $'Port > ' port
                    read -rp $'Path to file to send > ' filepath
                    if [[ ! -f $filepath ]]; then
                    echo -e "${BRIGHT_RED}File not found: $filepath${RESET}"
                    return
                    fi
                    echo -e "${BRIGHT_MAGENTA}Sending ${filepath} -> ${target}:${port}${RESET}"
                    outbase="$outdir/send_$(basename "$filepath")_${target}_${port}_$(date +%Y%m%d_%H%M%S).log"
                    # send file
                    "$nc_cmd" "$target" "$port" < "$filepath" |& tee "$outbase"
                    ;;
                2)
                    read -rp $'Listen port > ' port
                    read -rp $'Output filename (optional) > ' outname
                    outpath="$outdir/${outname:-received_$(date +%Y%m%d_%H%M%S)}"
                    echo -e "${BRIGHT_MAGENTA}Listening on port ${port}, saving to ${outpath}${RESET}"
                    # Attempt portable listen
                    if "$nc_cmd" -h 2>&1 | grep -qi -- "-p"; then
                    "$nc_cmd" -l -p "$port" > "$outpath"
                    else
                    "$nc_cmd" -l "$port" > "$outpath"
                    fi
                    echo -e "${DIM}Saved to ${outpath}${RESET}"
                    ;;
                *)
                    echo -e "${BRIGHT_RED}Invalid choice.${RESET}"
                    ;;
                esac
                ;;
            4)
                read -rp $'Target (ip/host) > ' target
                read -rp $'Port > ' port
                read -rp $'Protocol [tcp/udp] (tcp) > ' proto
                proto=${proto:-tcp}
                echo -e "${BRIGHT_MAGENTA}Banner grab ${target}:${port} (${proto})${RESET}"
                if [[ $proto == "udp" ]]; then
                "$nc_cmd" -u -v -w 3 "$target" "$port"
                else
                # Try a simple HTTP probe first, fallback to raw connect
                printf "HEAD / HTTP/1.0\r\n\r\n" | "$nc_cmd" -v -w 3 "$target" "$port" || "$nc_cmd" -v -w 3 "$target" "$port"
                fi
                ;;
            5)
                read -rp $'Enter custom nc args (example: -v -w 3 target port) > ' custom_args
                if [[ -z $custom_args ]]; then
                echo -e "${BRIGHT_RED}No custom args provided.${RESET}"
                return
                fi
                IFS=' ' read -r -a user_args <<< "$custom_args"
                echo -e "${BRIGHT_MAGENTA}Running: $nc_cmd ${user_args[*]}${RESET}"
                "$nc_cmd" "${user_args[@]}"
                ;;
            *)
                echo -e "${BRIGHT_RED}Invalid choice.${RESET}"
                ;;
            esac
        ;;
        3)
            echo -e "\n${BRIGHT_MAGENTA}Launching Tcpdump${RESET}"
            # Placeholder for Tcpdump functionality
        ;;
        4)
            echo -e "\n${BRIGHT_MAGENTA}Launching Wireshark (tshark)${RESET}"
            # Placeholder for tshark functionality
        ;;
        5)
            echo -e "\n${BRIGHT_MAGENTA}Launching Hping3${RESET}"
            # Placeholder for hping3 functionality
        ;;
        6)
            echo -e "\n${BRIGHT_MAGENTA}Launching Arp-scan${RESET}"
            # Placeholder for arp-scan functionality
        ;;
        7)
            echo -e "\n${BRIGHT_MAGENTA}Launching Masscan${RESET}"
            # Placeholder for masscan functionality
        ;;
        8)
            echo -e "\n${BRIGHT_MAGENTA}Launching Nikto${RESET}"
            # Placeholder for nikto functionality
        ;;
        9)
            echo -e "\n${BRIGHT_MAGENTA}Launching Dnsenum${RESET}"
            # Placeholder for dnsenum functionality
        ;;
        10)
            echo -e "\n${BRIGHT_MAGENTA}Launching Whatweb${RESET}"
            # Placeholder for whatweb functionality
        ;;
        0)
            echo -e "\n${BRIGHT_MAGENTA}Exiting...${RESET}"
            exit 0
            
            ;;
        *)
            echo -e "\n${BRIGHT_RED}Invalid choice. Please try again.${RESET}"
            ;;
    esac
    
    if [[ $choice != "0" ]]; then
        echo -e "\n${DIM}Press Enter to continue...${RESET}"
        read -r
    fi
}

# ============================================================================
# MAIN LOOP
# ============================================================================
main_loop() {
    display_title_middle_screen
    sleep 2
    
    while true; do
        clear
        display_banner_with_menu
        echo -ne "🕸️    ${BOLD}${BRIGHT_RED}FEED YOUR SPIDER: ${RESET}"
        read -r choice
        
        handle_menu_choice "$choice"
    done
}

main_loop