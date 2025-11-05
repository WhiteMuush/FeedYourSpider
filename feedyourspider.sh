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
readonly RED="$(tput setaf 6)"

# Bright colors
readonly BRIGHT_RED="$(tput setaf 9)"
readonly BRIGHT_GREEN="$(tput setaf 10)"
readonly BRIGHT_BLUE="$(tput setaf 12)"
readonly BRIGHT_MAGENTA="$(tput setaf 13)"
readonly BRIGHT_RED="$(tput setaf 14)"

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
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[1]${RESET} System Scan             "
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[2]${RESET} Network Discovery       "
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[3]${RESET} Performance Analysis    "
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[4]${RESET} Security Audit          "
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[5]${RESET} Log Analysis            "
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[6]${RESET} Full Spider Scan (ALL) "
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[7]${RESET} View Collected Data     "
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[8]${RESET} Install Dependencies"
        "${BOLD}${BRIGHT_MAGENTA}░${RESET}    ${BRIGHT_RED}[9]${RESET} Clean Data"
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
            # Confirm before launching
            read -r -p $'\nAre you sure to launch the system scan ? [yes/no]: ' confirm
            case "${confirm,,}" in
            y|yes)
                sleep 1
                local script_dir target rc
                script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
                target="$script_dir/tools/systemScan.sh"
                if [[ -f "$target" ]]; then
                if [[ -x "$target" ]]; then
                    echo -e "${DIM}Running ${target}...${RESET}"
                    "$target"
                    rc=$?
                else
                    echo -e "${DIM}${target} is not executable, running with bash...${RESET}"
                    bash "$target"
                    rc=$?
                fi

                if (( rc == 0 )); then
                    echo -e "${BRIGHT_MAGENTA}systemScan completed successfully (exit ${rc}).${RESET}"
                else
                    echo -e "${BRIGHT_RED}systemScan failed with exit code ${rc}.${RESET}"
                fi
                else
                echo -e "${BRIGHT_RED}systemScan script not found at: ${target}${RESET}"
                fi
                ;;
            *)
                echo -e "\n${BRIGHT_RED}System scan canceled by user.${RESET}"
                ;;
            esac
            ;;
        2)
            echo -e "\n${BRIGHT_MAGENTA}Launching Network Discovery...${RESET}"
            # TODO: Implement network discovery
            ;;
        3)
            echo -e "\n${BRIGHT_MAGENTA}Launching Performance Analysis...${RESET}"
            # TODO: Implement performance analysis
            ;;
        4)
            echo -e "\n${BRIGHT_MAGENTA}Launching Security Audit...${RESET}"
            # TODO: Implement security audit
            ;;
        5)
            echo -e "\n${BRIGHT_MAGENTA}Launching Log Analysis...${RESET}"
            # TODO: Implement log analysis
            ;;
        6)
            echo -e "\n${BRIGHT_MAGENTA}Launching Full Spider Scan...${RESET}"
            # TODO: Implement full scan
            ;;
        7)
            echo -e "\n${BRIGHT_MAGENTA}Displaying Collected Data...${RESET}"
            # TODO: Implement data viewer
            ;;
        8)
            echo -e "\n${BRIGHT_MAGENTA}Installing Dependencies...${RESET}"
            # TODO: Implement dependency installer
            ;;
        9)
            echo -e "\n${BRIGHT_MAGENTA}Cleaning Data...${RESET}"
            # TODO: Implement data cleanup
            ;;
        0)
            echo -e "\n${BRIGHT_GREEN}Spider is going to sleep... Goodbye!${RESET}\n"
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