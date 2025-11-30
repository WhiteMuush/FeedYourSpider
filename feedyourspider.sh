#!/bin/bash
# feedyourspider.sh
# Interactive toolkit launcher for common network/tools (nmap, nc, tcpdump, etc.)
# This version is the same functionality as the original but with explanatory comments.

# ============================================================================
# COLOR DEFINITIONS
# Define terminal control sequences for colored/format text output.
# ============================================================================
readonly RESET="$(tput sgr0)"        # reset attributes
readonly BOLD="$(tput bold)"
readonly DIM="$(tput dim)"

# Standard colors
readonly RED="$(tput setaf 1)"
readonly GREEN="$(tput setaf 2)"
readonly BLUE="$(tput setaf 4)"
readonly MAGENTA="$(tput setaf 5)"
readonly CYAN="$(tput setaf 6)"

# Bright colors (if terminal supports)
readonly BRIGHT_RED="$(tput setaf 9)"
readonly BRIGHT_GREEN="$(tput setaf 10)"
readonly BRIGHT_BLUE="$(tput setaf 12)"
readonly BRIGHT_MAGENTA="$(tput setaf 13)"
readonly BRIGHT_CYAN="$(tput setaf 14)"

# ============================================================================
# ASCII ART BANNER
# A block of multiline Unicode/emoji art printed to the left of the menu.
# Quoted with 'ASCII' to avoid variable/escape expansion.
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
# generate_menu builds an array of lines for the right-hand menu column.
# ============================================================================
generate_menu() {
    local -a menu_lines=(
        ""  # spacer line
        # Colored ASCII text header for the tool name
        "${BOLD}${BRIGHT_RED}____ ____ ____ ___     _   _ ____ _  _ ____    ____ ___  _ ___  ____ ____ ${RESET}"
        "${BOLD}${BRIGHT_RED}|___ |___ |___ |  \\     \\_/  |  | |  | |__/    [__  |__] | |  \\ |___ |__/ ${RESET}"
        "${BOLD}${BRIGHT_RED}|    |___ |___ |__/      |   |__| |__| |  \\    ___] |    | |__/ |___ |  \\ ${RESET}"
        "${BOLD}${BRIGHT_RED}                                                                          ${RESET}"
        ""
        # creator line includes OSC 8 hyperlink sequences to GitHub
        "${BRIGHT_MAGENTA}🕸️ Creator: \e]8;;https://github.com/WhiteMuush\aMelvin PETIT\e]8;;\a   ${BRIGHT_RED}${BOLD}Use only on authorized targets${RESET}          ${DIM}v0.0.1${RESET}"
        ""
        ""
        ""
        # menu header and items
        "${BOLD}${BRIGHT_MAGENTA}${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${DIM}Spider is hungry... Feed it with network data!${RESET}"
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
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[10]${RESET} Whatweb"  # NOTE: duplicate index in visual menu (mapped to 10 later)
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[0]${RESET}Exit"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}"
        ""
        ""
    )
    
    # Print the menu lines (each array element -> one output line)
    printf '%s\n' "${menu_lines[@]}"
}

# ============================================================================
# INFORMATION PANEL
# Small status/branding lines used for a centered title screen.
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
    # Get terminal size, fallback to 80x24 if tput fails
    local cols rows
    cols=$(tput cols 2>/dev/null || echo 80)
    rows=$(tput lines 2>/dev/null || echo 24)

    # Select a subset of lines to show for the title screen
    local -a lines=(
        "${INFO_PANEL[1]}"
        "${INFO_PANEL[2]}"
        "${INFO_PANEL[3]}"
        ""
        "BY MELVIN PETIT"
    )
    local h=${#lines[@]}

    # strip_esc: helper to remove ANSI escape sequences for accurate width calculations
    strip_esc() {
        sed -E 's/\x1B\[[0-9;?]*[ -/]*[@-~]//g; s/\x1B\][^\a]*\a//g'
    }

    # Compute maximum visible width among lines (after removing escapes)
    local max_w=0 raw visible_len line
    for line in "${lines[@]}"; do
        raw=$(printf "%s" "$line" | strip_esc)
        visible_len=${#raw}
        (( visible_len > max_w )) && max_w=$visible_len
    done

    # Calculate top and left offsets to center the block
    local top=$(( (rows - h) / 2 ))
    (( top < 0 )) && top=0
    local left=$(( (cols - max_w) / 2 ))
    (( left < 0 )) && left=0

    # Clear screen and print blank lines for vertical centering
    printf "\033c"
    for ((i=0; i<top; i++)); do printf "\n"; done

    # Print each line with left padding for horizontal centering
    for line in "${lines[@]}"; do
        printf "%*s%s\n" "$left" "" "$line"
    done
}

# ============================================================================
# DISPLAY ASCII ART + MENU SIDE-BY-SIDE
# The ASCII art is printed on the left, menu on the right, line-aligned.
# ============================================================================
display_banner_with_menu() {
    local -a ascii_lines menu_lines
    
    # Read ASCII art into an array (preserve newlines)
    IFS=$'\n' read -r -d '' -a ascii_lines <<< "$ASCII_ART" || true
    # Generate menu text and read into an array
    IFS=$'\n' read -r -d '' -a menu_lines <<< "$(generate_menu)" || true
    
    local ascii_count=${#ascii_lines[@]}
    local menu_count=${#menu_lines[@]}
    local max_lines=$((ascii_count > menu_count ? ascii_count : menu_count))
    
    # Determine width of ASCII art to align menu correctly
    local max_ascii_width=0
    for line in "${ascii_lines[@]}"; do
        ((${#line} > max_ascii_width)) && max_ascii_width=${#line}
    done
    
    local spacing="    "  # gap between art and menu
    
    # Iterate through each output row and print art + padding + menu line
    for ((i=0; i<max_lines; i++)); do
        local ascii_line="${ascii_lines[i]:-}"
        local menu_line="${menu_lines[i]:-}"
        
        # Color the ASCII art region
        local colored_ascii="${BRIGHT_MAGENTA}${ascii_line}${RESET}"
        local pad=$((max_ascii_width - ${#ascii_line}))
        ((pad < 0)) && pad=0
        
        # Print left margin, colored art, pad to maintain width, spacing, then menu
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
# handle_menu_choice receives a numeric option and runs the corresponding tool.
# Each case usually checks for the command, attempts to install it if missing,
# then prompts the user for parameters and runs the tool, saving outputs.
# ============================================================================
handle_menu_choice() {
    local choice=$1
    
    case $choice in
        1)
        # Nmap: check/install -> prompt target -> choose profile -> run
        if ! command -v nmap >/dev/null 2>&1; then
            echo -e "${BRIGHT_MAGENTA}nmap not found. Attempting to install...${RESET}"
            if [[ "$(uname)" == "Darwin" ]]; then
                # macOS: use Homebrew if available
                if command -v brew >/dev/null 2>&1; then
                    brew install nmap || { echo -e "${BRIGHT_RED}Failed to install nmap via brew.${RESET}"; return; }
                else
                    echo -e "${BRIGHT_RED}Homebrew not found. Please install Homebrew or nmap manually.${RESET}"
                    return
                fi
            else
                # Linux: try common package managers
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

            # re-check after attempted install
            if ! command -v nmap >/dev/null 2>&1; then
                echo -e "${BRIGHT_RED}nmap still not available after install attempt.${RESET}"
                return
            fi

            echo -e "${BRIGHT_MAGENTA}nmap installed successfully.${RESET}"
        fi
            echo -e "\n${BRIGHT_MAGENTA}Launching Nmap${RESET}"

            # Prompt for target; basic validation for empty input
            read -rp $'\nTarget (ip/host or CIDR) > ' target
            if [[ -z $target ]]; then
                echo -e "${BRIGHT_RED}No target provided.${RESET}"
                return
            fi

            # Ensure nmap is available (defensive)
            if ! command -v nmap >/dev/null 2>&1; then
                echo -e "${BRIGHT_RED}nmap is not installed. Install it (e.g. sudo apt install nmap) and try again.${RESET}"
                return
            fi

            # Prepare output directory and safe filename base
            outdir="$HOME/feedyourspider_nmap"
            mkdir -p "$outdir"
            safe_target=$(printf "%s" "$target" | sed 's/[^A-Za-z0-9._-]/_/g')
            outbase="$outdir/scan_${safe_target}_$(date +%Y%m%d_%H%M%S)"

            # Ask for a scan profile and map to argv array (safer quoting)
            echo
            echo "Select scan type:"
            echo "  [1] Quick (top ports)"
            echo "  [2] Service/version (-sV + default scripts)"
            echo "  [3] Aggressive (-A)"
            echo "  [4] All ports (-p-)"
            echo "  [5] SYN stealth (-sS)"
            echo "  [6] Custom args"
            read -rp $'Choice [1-6] > ' nmap_choice

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
                    # Custom arguments: split on spaces into an array
                    read -rp $'Enter custom nmap args (example: -p 1-65535 -sV) > ' custom_args
                    if [[ -z $custom_args ]]; then
                        echo -e "${BRIGHT_RED}No custom args provided. Aborting.${RESET}"
                        return
                    fi
                    IFS=' ' read -r -a user_args <<< "$custom_args"
                    nmap_args=("${user_args[@]}" -oA "$outbase")
                    ;;
                *)
                    echo -e "${BRIGHT_RED}Invalid choice.${RESET}"
                    return
                    ;;
            esac

            echo -e "\n${DIM}Saving results to ${outbase}.{nmap,gnmap,xml}${RESET}"

            # Decide whether sudo is likely required (simple heuristic)
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
        # Netcat (nc): check/install -> provide various client/server/file-transfer options
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
                # Try common names/packages for netcat across distros
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

            if ! command -v nc >/dev/null 2>&1 && ! command -v netcat >/dev/null 2>&1; then
                echo -e "${BRIGHT_RED}netcat still not available after install attempt.${RESET}"
                return
            fi

            echo -e "${BRIGHT_MAGENTA}netcat installed successfully.${RESET}"
        fi
            echo -e "\n${BRIGHT_MAGENTA}Launching Netcat${RESET}"

            # Determine available command name for netcat
            if ! command -v nc >/dev/null 2>&1 && ! command -v netcat >/dev/null 2>&1; then
            echo -e "${BRIGHT_RED}netcat (nc) is not installed. Install it (e.g. sudo apt install netcat-openbsd) and try again.${RESET}"
            return
            fi
            nc_cmd=$(command -v nc || command -v netcat)

            outdir="$HOME/feedyourspider_netcat"
            mkdir -p "$outdir"

            # Menu of netcat use-cases
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
                # client connect: support tcp/udp and save session to log
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
                # listen mode: portable handling for -l and -p variants
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
                # Try to be portable between OpenBSD nc and other implementations
                if "$nc_cmd" -h 2>&1 | grep -qi -- "-p"; then
                    "$nc_cmd" -l -p "$port" |& tee "$outbase"
                else
                    "$nc_cmd" -l "$port" |& tee "$outbase"
                fi
                fi
                ;;
            3)
                # File transfer: either send (client) or receive (server)
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
                    "$nc_cmd" "$target" "$port" < "$filepath" |& tee "$outbase"
                    ;;
                2)
                    read -rp $'Listen port > ' port
                    read -rp $'Output filename (optional) > ' outname
                    outpath="$outdir/${outname:-received_$(date +%Y%m%d_%H%M%S)}"
                    echo -e "${BRIGHT_MAGENTA}Listening on port ${port}, saving to ${outpath}${RESET}"
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
                # Banner grab helper: attempt HTTP HEAD then raw connect fallback
                read -rp $'Target (ip/host) > ' target
                read -rp $'Port > ' port
                read -rp $'Protocol [tcp/udp] (tcp) > ' proto
                proto=${proto:-tcp}
                echo -e "${BRIGHT_MAGENTA}Banner grab ${target}:${port} (${proto})${RESET}"
                if [[ $proto == "udp" ]]; then
                "$nc_cmd" -u -v -w 3 "$target" "$port"
                else
                printf "HEAD / HTTP/1.0\r\n\r\n" | "$nc_cmd" -v -w 3 "$target" "$port" || "$nc_cmd" -v -w 3 "$target" "$port"
                fi
                ;;
            5)
                # Custom arguments directly passed through
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
            # Tcpdump: install if missing, then capture modes with filters, write pcap
            if ! command -v tcpdump >/dev/null 2>&1; then
                echo -e "${BRIGHT_MAGENTA}tcpdump not found. Attempting to install...${RESET}"
                if [[ "$(uname)" == "Darwin" ]]; then
                    if command -v brew >/dev/null 2>&1; then
                        brew install tcpdump || { echo -e "${BRIGHT_RED}Failed to install tcpdump via brew.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Homebrew not found. Please install Homebrew or tcpdump manually.${RESET}"; return
                    fi
                else
                    if command -v apt-get >/dev/null 2>&1; then
                        sudo apt-get update && sudo apt-get install -y tcpdump || { echo -e "${BRIGHT_RED}apt-get install failed.${RESET}"; return; }
                    elif command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y tcpdump || { echo -e "${BRIGHT_RED}dnf install failed.${RESET}"; return; }
                    elif command -v yum >/dev/null 2>&1; then
                        sudo yum install -y tcpdump || { echo -e "${BRIGHT_RED}yum install failed.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Unsupported system or package manager. Please install tcpdump manually.${RESET}"; return
                    fi
                fi
                if ! command -v tcpdump >/dev/null 2>&1; then
                    echo -e "${BRIGHT_RED}tcpdump still not available after install attempt.${RESET}"; return
                fi
                echo -e "${BRIGHT_MAGENTA}tcpdump installed successfully.${RESET}"
            fi

            echo -e "\n${BRIGHT_MAGENTA}Launching Tcpdump${RESET}"
            outdir="$HOME/feedyourspider_tcpdump"
            mkdir -p "$outdir"

            echo
            echo "Tcpdump modes:"
            echo "  [1] Capture on interface"
            echo "  [2] Capture specific port"
            echo "  [3] Capture specific host"
            echo "  [4] Custom filter"
            read -rp $'Choice [1-4] > ' tcpdump_choice

            declare -a tcpdump_args=(-i any)
            outbase="$outdir/capture_$(date +%Y%m%d_%H%M%S)"

            case "$tcpdump_choice" in
                1)
                    read -rp $'Interface (or "any") > ' iface
                    tcpdump_args=(-i "${iface:-any}" -w "$outbase.pcap")
                    ;;
                2)
                    read -rp $'Port > ' port
                    tcpdump_args=(-i any "port $port" -w "$outbase.pcap")
                    ;;
                3)
                    read -rp $'Host IP > ' host
                    tcpdump_args=(-i any "host $host" -w "$outbase.pcap")
                    ;;
                4)
                    read -rp $'Filter expression > ' filter
                    tcpdump_args=(-i any "$filter" -w "$outbase.pcap")
                    ;;
                *)
                    echo -e "${BRIGHT_RED}Invalid choice.${RESET}"; return ;;
            esac

            echo -e "${DIM}Saving to ${outbase}.pcap${RESET}"
            echo -e "${BRIGHT_MAGENTA}Running: sudo tcpdump ${tcpdump_args[*]}${RESET}"
            echo -e "${DIM}Press Ctrl+C to stop${RESET}"
            sudo tcpdump "${tcpdump_args[@]}"
        ;;
        4)
            # Tshark (wireshark CLI): install if missing, capture/read/statistics modes
            if ! command -v tshark >/dev/null 2>&1; then
                echo -e "${BRIGHT_MAGENTA}tshark not found. Attempting to install...${RESET}"
                if [[ "$(uname)" == "Darwin" ]]; then
                    if command -v brew >/dev/null 2>&1; then
                        brew install wireshark || { echo -e "${BRIGHT_RED}Failed to install wireshark via brew.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Homebrew not found. Please install Homebrew or wireshark manually.${RESET}"; return
                    fi
                else
                    if command -v apt-get >/dev/null 2>&1; then
                        sudo apt-get update && sudo apt-get install -y wireshark tshark || { echo -e "${BRIGHT_RED}apt-get install failed.${RESET}"; return; }
                    elif command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y wireshark || { echo -e "${BRIGHT_RED}dnf install failed.${RESET}"; return; }
                    elif command -v yum >/dev/null 2>&1; then
                        sudo yum install -y wireshark || { echo -e "${BRIGHT_RED}yum install failed.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Unsupported system or package manager. Please install wireshark manually.${RESET}"; return
                    fi
                fi
                if ! command -v tshark >/dev/null 2>&1; then
                    echo -e "${BRIGHT_RED}tshark still not available after install attempt.${RESET}"; return
                fi
                echo -e "${BRIGHT_MAGENTA}tshark installed successfully.${RESET}"
            fi

            echo -e "\n${BRIGHT_MAGENTA}Launching Wireshark (tshark)${RESET}"
            outdir="$HOME/feedyourspider_tshark"
            mkdir -p "$outdir"

            echo
            echo "Tshark modes:"
            echo "  [1] Live capture on interface"
            echo "  [2] Read pcap file"
            echo "  [3] Packet statistics"
            read -rp $'Choice [1-3] > ' tshark_choice

            case "$tshark_choice" in
                1)
                    read -rp $'Interface (or "any") > ' iface
                    outbase="$outdir/capture_$(date +%Y%m%d_%H%M%S).pcap"
                    echo -e "${BRIGHT_MAGENTA}Capturing on ${iface:-any}, saving to ${outbase}${RESET}"
                    echo -e "${DIM}Press Ctrl+C to stop${RESET}"
                    sudo tshark -i "${iface:-any}" -w "$outbase"
                    ;;
                2)
                    read -rp $'Path to pcap file > ' pcapfile
                    if [[ ! -f $pcapfile ]]; then
                        echo -e "${BRIGHT_RED}File not found: $pcapfile${RESET}"; return
                    fi
                    # Print a preview of the pcap contents
                    tshark -r "$pcapfile" | head -50
                    ;;
                3)
                    read -rp $'Path to pcap file > ' pcapfile
                    if [[ ! -f $pcapfile ]]; then
                        echo -e "${BRIGHT_RED}File not found: $pcapfile${RESET}"; return
                    fi
                    echo -e "${BRIGHT_MAGENTA}Top protocols:${RESET}"
                    tshark -r "$pcapfile" -q -z io,phs
                    ;;
                *)
                    echo -e "${BRIGHT_RED}Invalid choice.${RESET}"; return ;;
            esac
        ;;
        5)
            # Hping3: install if missing, then several common modes (SYN, UDP, ICMP)
            if ! command -v hping3 >/dev/null 2>&1; then
                echo -e "${BRIGHT_MAGENTA}hping3 not found. Attempting to install...${RESET}"
                if [[ "$(uname)" == "Darwin" ]]; then
                    if command -v brew >/dev/null 2>&1; then
                        brew install hping3 || { echo -e "${BRIGHT_RED}Failed to install hping3 via brew.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Homebrew not found. Please install Homebrew or hping3 manually.${RESET}"; return
                    fi
                else
                    if command -v apt-get >/dev/null 2>&1; then
                        sudo apt-get update && sudo apt-get install -y hping3 || { echo -e "${BRIGHT_RED}apt-get install failed.${RESET}"; return; }
                    elif command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y hping3 || { echo -e "${BRIGHT_RED}dnf install failed.${RESET}"; return; }
                    elif command -v yum >/dev/null 2>&1; then
                        sudo yum install -y hping3 || { echo -e "${BRIGHT_RED}yum install failed.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Unsupported system or package manager. Please install hping3 manually.${RESET}"; return
                    fi
                fi
                if ! command -v hping3 >/dev/null 2>&1; then
                    echo -e "${BRIGHT_RED}hping3 still not available after install attempt.${RESET}"; return
                fi
                echo -e "${BRIGHT_MAGENTA}hping3 installed successfully.${RESET}"
            fi

            echo -e "\n${BRIGHT_MAGENTA}Launching Hping3${RESET}"
            echo
            echo "Hping3 modes:"
            echo "  [1] TCP SYN scan"
            echo "  [2] UDP ping"
            echo "  [3] ICMP echo"
            echo "  [4] Custom args"
            read -rp $'Choice [1-4] > ' hping_choice

            case "$hping_choice" in
                1)
                    read -rp $'Target > ' target
                    read -rp $'Port > ' port
                    echo -e "${BRIGHT_MAGENTA}Running TCP SYN scan on ${target}:${port}${RESET}"
                    sudo hping3 -S --dport "$port" "$target"
                    ;;
                2)
                    read -rp $'Target > ' target
                    echo -e "${BRIGHT_MAGENTA}Running UDP ping to ${target}${RESET}"
                    sudo hping3 --udp "$target"
                    ;;
                3)
                    read -rp $'Target > ' target
                    echo -e "${BRIGHT_MAGENTA}Running ICMP echo to ${target}${RESET}"
                    sudo hping3 -1 "$target"
                    ;;
                4)
                    read -rp $'Enter custom hping3 args > ' custom_args
                    if [[ -z $custom_args ]]; then
                        echo -e "${BRIGHT_RED}No custom args provided.${RESET}"; return
                    fi
                    IFS=' ' read -r -a user_args <<< "$custom_args"
                    echo -e "${BRIGHT_MAGENTA}Running: sudo hping3 ${user_args[*]}${RESET}"
                    sudo hping3 "${user_args[@]}"
                    ;;
                *)
                    echo -e "${BRIGHT_RED}Invalid choice.${RESET}"; return ;;
            esac
        ;;
        6)
            # arp-scan: local network scanning; install if missing
            if ! command -v arp-scan >/dev/null 2>&1; then
                echo -e "${BRIGHT_MAGENTA}arp-scan not found. Attempting to install...${RESET}"
                if [[ "$(uname)" == "Darwin" ]]; then
                    if command -v brew >/dev/null 2>&1; then
                        brew install arp-scan || { echo -e "${BRIGHT_RED}Failed to install arp-scan via brew.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Homebrew not found. Please install Homebrew or arp-scan manually.${RESET}"; return
                    fi
                else
                    if command -v apt-get >/dev/null 2>&1; then
                        sudo apt-get update && sudo apt-get install -y arp-scan || { echo -e "${BRIGHT_RED}apt-get install failed.${RESET}"; return; }
                    elif command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y arp-scan || { echo -e "${BRIGHT_RED}dnf install failed.${RESET}"; return; }
                    elif command -v yum >/dev/null 2>&1; then
                        sudo yum install -y arp-scan || { echo -e "${BRIGHT_RED}yum install failed.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Unsupported system or package manager. Please install arp-scan manually.${RESET}"; return
                    fi
                fi
                if ! command -v arp-scan >/dev/null 2>&1; then
                    echo -e "${BRIGHT_RED}arp-scan still not available after install attempt.${RESET}"; return
                fi
                echo -e "${BRIGHT_MAGENTA}arp-scan installed successfully.${RESET}"
            fi

            echo -e "\n${BRIGHT_MAGENTA}Launching Arp-scan${RESET}"
            outdir="$HOME/feedyourspider_arpscan"
            mkdir -p "$outdir"

            echo
            echo "Arp-scan modes:"
            echo "  [1] Scan local network"
            echo "  [2] Scan specific range (CIDR)"
            echo "  [3] Custom args"
            read -rp $'Choice [1-3] > ' arpscan_choice

            case "$arpscan_choice" in
                1)
                    outbase="$outdir/localnet_$(date +%Y%m%d_%H%M%S).txt"
                    echo -e "${BRIGHT_MAGENTA}Scanning local network, saving to ${outbase}${RESET}"
                    sudo arp-scan -l | tee "$outbase"
                    ;;
                2)
                    read -rp $'Network range (CIDR, e.g., 192.168.1.0/24) > ' range
                    outbase="$outdir/scan_${range//\//_}_$(date +%Y%m%d_%H%M%S).txt"
                    echo -e "${BRIGHT_MAGENTA}Scanning ${range}, saving to ${outbase}${RESET}"
                    sudo arp-scan "$range" | tee "$outbase"
                    ;;
                3)
                    read -rp $'Enter custom arp-scan args > ' custom_args
                    if [[ -z $custom_args ]]; then
                        echo -e "${BRIGHT_RED}No custom args provided.${RESET}"; return
                    fi
                    IFS=' ' read -r -a user_args <<< "$custom_args"
                    echo -e "${BRIGHT_MAGENTA}Running: sudo arp-scan ${user_args[*]}${RESET}"
                    sudo arp-scan "${user_args[@]}"
                    ;;
                *)
                    echo -e "${BRIGHT_RED}Invalid choice.${RESET}"; return ;;
            esac
        ;;
        7)
            # Masscan: fast Internet-scale port scanner; install then run with user-specified ports
            if ! command -v masscan >/dev/null 2>&1; then
                echo -e "${BRIGHT_MAGENTA}masscan not found. Attempting to install...${RESET}"
                if [[ "$(uname)" == "Darwin" ]]; then
                    if command -v brew >/dev/null 2>&1; then
                        brew install masscan || { echo -e "${BRIGHT_RED}Failed to install masscan via brew.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Homebrew not found. Please install Homebrew or masscan manually.${RESET}"; return
                    fi
                else
                    if command -v apt-get >/dev/null 2>&1; then
                        sudo apt-get update && sudo apt-get install -y masscan || { echo -e "${BRIGHT_RED}apt-get install failed.${RESET}"; return; }
                    elif command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y masscan || { echo -e "${BRIGHT_RED}dnf install failed.${RESET}"; return; }
                    elif command -v yum >/dev/null 2>&1; then
                        sudo yum install -y masscan || { echo -e "${BRIGHT_RED}yum install failed.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Unsupported system or package manager. Please install masscan manually.${RESET}"; return
                    fi
                fi
                if ! command -v masscan >/dev/null 2>&1; then
                    echo -e "${BRIGHT_RED}masscan still not available after install attempt.${RESET}"; return
                fi
                echo -e "${BRIGHT_MAGENTA}masscan installed successfully.${RESET}"
            fi

            echo -e "\n${BRIGHT_MAGENTA}Launching Masscan${RESET}"
            outdir="$HOME/feedyourspider_masscan"
            mkdir -p "$outdir"

            read -rp $'Target (IP or CIDR) > ' target
            read -rp $'Ports (e.g., 80,443,1-1000) > ' ports
            outbase="$outdir/masscan_${target//\//_}_$(date +%Y%m%d_%H%M%S)"

            echo -e "${BRIGHT_MAGENTA}Running masscan on ${target} for ports ${ports}${RESET}"
            echo -e "${DIM}Saving to ${outbase}.gnmap${RESET}"
            # default rate set to 5000 (user can change in code or custom args)
            sudo masscan "$target" -p "$ports" -oG "$outbase.gnmap" --rate 5000
        ;;
        8)
            # Nikto: web vulnerability scanner; install and run modes
            if ! command -v nikto >/dev/null 2>&1; then
                echo -e "${BRIGHT_MAGENTA}nikto not found. Attempting to install...${RESET}"
                if [[ "$(uname)" == "Darwin" ]]; then
                    if command -v brew >/dev/null 2>&1; then
                        brew install nikto || { echo -e "${BRIGHT_RED}Failed to install nikto via brew.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Homebrew not found. Please install Homebrew or nikto manually.${RESET}"; return
                    fi
                else
                    if command -v apt-get >/dev/null 2>&1; then
                        sudo apt-get update && sudo apt-get install -y nikto || { echo -e "${BRIGHT_RED}apt-get install failed.${RESET}"; return; }
                    elif command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y nikto || { echo -e "${BRIGHT_RED}dnf install failed.${RESET}"; return; }
                    elif command -v yum >/dev/null 2>&1; then
                        sudo yum install -y nikto || { echo -e "${BRIGHT_RED}yum install failed.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Unsupported system or package manager. Please install nikto manually.${RESET}"; return
                    fi
                fi
                if ! command -v nikto >/dev/null 2>&1; then
                    echo -e "${BRIGHT_RED}nikto still not available after install attempt.${RESET}"; return
                fi
                echo -e "${BRIGHT_MAGENTA}nikto installed successfully.${RESET}"
            fi

            echo -e "\n${BRIGHT_MAGENTA}Launching Nikto${RESET}"
            outdir="$HOME/feedyourspider_nikto"
            mkdir -p "$outdir"

            echo
            echo "Nikto modes:"
            echo "  [1] Scan URL"
            echo "  [2] Scan host:port"
            echo "  [3] Custom args"
            read -rp $'Choice [1-3] > ' nikto_choice

            case "$nikto_choice" in
                1)
                    read -rp $'URL (e.g., http://example.com) > ' url
                    outbase="$outdir/scan_$(date +%Y%m%d_%H%M%S).txt"
                    echo -e "${BRIGHT_MAGENTA}Scanning ${url}, saving to ${outbase}${RESET}"
                    nikto -url "$url" -o "$outbase"
                    ;;
                2)
                    read -rp $'Host > ' host
                    read -rp $'Port (80) > ' port
                    port=${port:-80}
                    outbase="$outdir/scan_${host}_${port}_$(date +%Y%m%d_%H%M%S).txt"
                    echo -e "${BRIGHT_MAGENTA}Scanning ${host}:${port}, saving to ${outbase}${RESET}"
                    nikto -h "$host" -p "$port" -o "$outbase"
                    ;;
                3)
                    read -rp $'Enter custom nikto args > ' custom_args
                    if [[ -z $custom_args ]]; then
                        echo -e "${BRIGHT_RED}No custom args provided.${RESET}"; return
                    fi
                    IFS=' ' read -r -a user_args <<< "$custom_args"
                    echo -e "${BRIGHT_MAGENTA}Running: nikto ${user_args[*]}${RESET}"
                    nikto "${user_args[@]}"
                    ;;
                *)
                    echo -e "${BRIGHT_RED}Invalid choice.${RESET}"; return ;;
            esac
        ;;
        9)
            # dnsenum: DNS enumeration tool; install and run
            if ! command -v dnsenum >/dev/null 2>&1; then
                echo -e "${BRIGHT_MAGENTA}dnsenum not found. Attempting to install...${RESET}"
                if [[ "$(uname)" == "Darwin" ]]; then
                    if command -v brew >/dev/null 2>&1; then
                        brew install dnsenum || { echo -e "${BRIGHT_RED}Failed to install dnsenum via brew.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Homebrew not found. Please install Homebrew or dnsenum manually.${RESET}"; return
                    fi
                else
                    if command -v apt-get >/dev/null 2>&1; then
                        sudo apt-get update && sudo apt-get install -y dnsenum || { echo -e "${BRIGHT_RED}apt-get install failed.${RESET}"; return; }
                    elif command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y dnsenum || { echo -e "${BRIGHT_RED}dnf install failed.${RESET}"; return; }
                    elif command -v yum >/dev/null 2>&1; then
                        sudo yum install -y dnsenum || { echo -e "${BRIGHT_RED}yum install failed.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Unsupported system or package manager. Please install dnsenum manually.${RESET}"; return
                    fi
                fi
                if ! command -v dnsenum >/dev/null 2>&1; then
                    echo -e "${BRIGHT_RED}dnsenum still not available after install attempt.${RESET}"; return
                fi
                echo -e "${BRIGHT_MAGENTA}dnsenum installed successfully.${RESET}"
            fi

            echo -e "\n${BRIGHT_MAGENTA}Launching Dnsenum${RESET}"
            outdir="$HOME/feedyourspider_dnsenum"
            mkdir -p "$outdir"

            read -rp $'Domain > ' domain
            outbase="$outdir/enum_${domain}_$(date +%Y%m%d_%H%M%S).txt"

            echo -e "${BRIGHT_MAGENTA}Enumerating DNS for ${domain}${RESET}"
            echo -e "${DIM}Saving to ${outbase}${RESET}"
            dnsenum "$domain" | tee "$outbase"
        ;;
        10)
            # whatweb: fingerprint web apps; note menu printed earlier used 9 twice
            if ! command -v whatweb >/dev/null 2>&1; then
                echo -e "${BRIGHT_MAGENTA}whatweb not found. Attempting to install...${RESET}"
                if [[ "$(uname)" == "Darwin" ]]; then
                    if command -v brew >/dev/null 2>&1; then
                        brew install whatweb || { echo -e "${BRIGHT_RED}Failed to install whatweb via brew.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Homebrew not found. Please install Homebrew or whatweb manually.${RESET}"; return
                    fi
                else
                    if command -v apt-get >/dev/null 2>&1; then
                        sudo apt-get update && sudo apt-get install -y whatweb || { echo -e "${BRIGHT_RED}apt-get install failed.${RESET}"; return; }
                    elif command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y whatweb || { echo -e "${BRIGHT_RED}dnf install failed.${RESET}"; return; }
                    elif command -v yum >/dev/null 2>&1; then
                        sudo yum install -y whatweb || { echo -e "${BRIGHT_RED}yum install failed.${RESET}"; return; }
                    else
                        echo -e "${BRIGHT_RED}Unsupported system or package manager. Please install whatweb manually.${RESET}"; return
                    fi
                fi
                if ! command -v whatweb >/dev/null 2>&1; then
                    echo -e "${BRIGHT_RED}whatweb still not available after install attempt.${RESET}"; return
                fi
                echo -e "${BRIGHT_MAGENTA}whatweb installed successfully.${RESET}"
            fi

            echo -e "\n${BRIGHT_MAGENTA}Launching Whatweb${RESET}"
            outdir="$HOME/feedyourspider_whatweb"
            mkdir -p "$outdir"

            echo
            echo "Whatweb modes:"
            echo "  [1] Identify URL (verbose)"
            echo "  [2] Identify URL (quiet)"
            echo "  [3] Identify URL (all plugins)"
            echo "  [4] Custom args"
            read -rp $'Choice [1-4] > ' whatweb_choice

            case "$whatweb_choice" in
                1)
                    read -rp $'URL > ' url
                    outbase="$outdir/identify_$(date +%Y%m%d_%H%M%S).txt"
                    echo -e "${BRIGHT_MAGENTA}Identifying ${url}${RESET}"
                    whatweb -v "$url" | tee "$outbase"
                    ;;
                2)
                    read -rp $'URL > ' url
                    outbase="$outdir/identify_$(date +%Y%m%d_%H%M%S).txt"
                    echo -e "${BRIGHT_MAGENTA}Identifying ${url}${RESET}"
                    whatweb -q "$url" | tee "$outbase"
                    ;;
                3)
                    read -rp $'URL > ' url
                    outbase="$outdir/identify_$(date +%Y%m%d_%H%M%S).txt"
                    echo -e "${BRIGHT_MAGENTA}Identifying ${url} with all plugins${RESET}"
                    whatweb -a 4 "$url" | tee "$outbase"
                    ;;
                4)
                    read -rp $'Enter custom whatweb args > ' custom_args
                    if [[ -z $custom_args ]]; then
                        echo -e "${BRIGHT_RED}No custom args provided.${RESET}"; return
                    fi
                    IFS=' ' read -r -a user_args <<< "$custom_args"
                    echo -e "${BRIGHT_MAGENTA}Running: whatweb ${user_args[*]}${RESET}"
                    whatweb "${user_args[@]}"
                    ;;
                *)
                    echo -e "${BRIGHT_RED}Invalid choice.${RESET}"; return ;;
            esac
        ;;
        0)
            # Exit option
            echo -e "\n${BRIGHT_MAGENTA}Exiting...${RESET}"
            exit 0
            
            ;;
        *)
            # Invalid menu choice
            echo -e "\n${BRIGHT_RED}Invalid choice. Please try again.${RESET}"
            ;;
    esac
    
    # Pause before returning to main menu unless user chose exit
    if [[ $choice != "0" ]]; then
        echo -e "\n${DIM}Press Enter to continue...${RESET}"
        read -r
    fi
}

# ============================================================================
# MAIN LOOP
# Shows the centered title screen briefly, then runs the interactive menu loop.
# ============================================================================
main_loop() {
    display_title_middle_screen
    sleep 2
    
    while true; do
        clear
        display_banner_with_menu
        # prompt on the right-hand side for a numeric choice
        echo -ne "🕸️    ${BOLD}${BRIGHT_RED}FEED YOUR SPIDER: ${RESET}"
        read -r choice
        
        handle_menu_choice "$choice"
    done
}

# Start the interactive main loop when script is executed
main_loop