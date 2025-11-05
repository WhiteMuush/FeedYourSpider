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
readonly YELLOW="$(tput setaf 3)"
readonly BLUE="$(tput setaf 4)"
readonly MAGENTA="$(tput setaf 5)"
readonly CYAN="$(tput setaf 6)"

# Bright colors
readonly BRIGHT_RED="$(tput setaf 9)"
readonly BRIGHT_GREEN="$(tput setaf 10)"
readonly BRIGHT_YELLOW="$(tput setaf 11)"
readonly BRIGHT_BLUE="$(tput setaf 12)"
readonly BRIGHT_MAGENTA="$(tput setaf 13)"
readonly BRIGHT_CYAN="$(tput setaf 14)"

# ============================================================================
# MENU ITEMS
# ============================================================================
generate_info() {
    local -a menu_lines=(
        ""
        "${BOLD}${BRIGHT_RED}____ ____ ____ ___     _   _ ____ _  _ ____    ____ ___  _ ___  ____ ____ ${RESET}"
        "${BOLD}${BRIGHT_RED}|___ |___ |___ |  \\     \\_/  |  | |  | |__/    [__  |__] | |  \\ |___ |__/ ${RESET}"
        "${BOLD}${BRIGHT_RED}|    |___ |___ |__/      |   |__| |__| |  \\    ___] |    | |__/ |___ |  \\ ${RESET}"
        "${BOLD}${BRIGHT_RED}                                                                          ${RESET}"
        ""
    )
    
    printf '%s\n' "${menu_lines[@]}"
}

# ============================================================================
# DATABASE MANAGEMENT
# ============================================================================
SPIDER_DB="${HOME}/.spider_toolkit/spider.db"
SPIDER_DIR="${HOME}/.spider_toolkit"

init_database() {
    mkdir -p "$SPIDER_DIR"
    
    if ! command -v sqlite3 &> /dev/null; then
        echo -e "${YELLOW}SQLite3 not found. Installing...${RESET}"
        sudo apt-get update -qq && sudo apt-get install -y sqlite3 &> /dev/null || {
            echo -e "${RED}Failed to install SQLite3${RESET}"
            return 1
        }
    fi
    
    sqlite3 "$SPIDER_DB" <<EOF
CREATE TABLE IF NOT EXISTS system_scans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    hostname TEXT,
    os_info TEXT,
    kernel TEXT,
    uptime TEXT,
    load_avg TEXT,
    cpu_usage REAL,
    ram_total INTEGER,
    ram_used INTEGER,
    ram_free INTEGER,
    swap_total INTEGER,
    swap_used INTEGER,
    disk_usage TEXT,
    health_score INTEGER,
    warnings TEXT,
    raw_data TEXT
);

CREATE TABLE IF NOT EXISTS processes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    scan_id INTEGER,
    pid INTEGER,
    user TEXT,
    cpu REAL,
    mem REAL,
    command TEXT,
    FOREIGN KEY (scan_id) REFERENCES system_scans(id)
);
EOF
}

# ============================================================================
# SYSTEM SCAN MODULE
# ============================================================================

collect_system_info() {
    local data_json=""
    
    echo -e "${BRIGHT_RED}🕷️  Spider is crawling through your system...${RESET}\n"
    
    # OS Info
    echo -ne "${DIM}[1/8]${RESET} Collecting OS information... "
    local hostname=$(hostname)
    local os_info=$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2)
    local kernel=$(uname -r)
    echo -e "${GREEN}✓${RESET}"
    
    # Uptime
    echo -ne "${DIM}[2/8]${RESET} Checking system uptime... "
    local uptime=$(uptime -p)
    local boot_time=$(who -b | awk '{print $3, $4}')
    echo -e "${GREEN}✓${RESET}"
    
    # Load Average
    echo -ne "${DIM}[3/8]${RESET} Measuring load average... "
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | xargs)
    echo -e "${GREEN}✓${RESET}"
    
    # CPU
    echo -ne "${DIM}[4/8]${RESET} Analyzing CPU usage... "
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local cpu_cores=$(nproc)
    echo -e "${GREEN}✓${RESET}"
    
    # RAM
    echo -ne "${DIM}[5/8]${RESET} Checking memory... "
    local ram_total=$(free -m | awk 'NR==2{print $2}')
    local ram_used=$(free -m | awk 'NR==2{print $3}')
    local ram_free=$(free -m | awk 'NR==2{print $4}')
    local ram_percent=$(awk "BEGIN {printf \"%.1f\", ($ram_used/$ram_total)*100}")
    
    local swap_total=$(free -m | awk 'NR==3{print $2}')
    local swap_used=$(free -m | awk 'NR==3{print $3}')
    local swap_percent=0
    if [[ $swap_total -gt 0 ]]; then
        swap_percent=$(awk "BEGIN {printf \"%.1f\", ($swap_used/$swap_total)*100}")
    fi
    echo -e "${GREEN}✓${RESET}"
    
    # Disk
    echo -ne "${DIM}[6/8]${RESET} Scanning disk usage... "
    local disk_data=$(df -h / | awk 'NR==2{print $2","$3","$4","$5}')
    IFS=',' read -r disk_total disk_used disk_free disk_percent <<< "$disk_data"
    disk_percent=${disk_percent%\%}
    echo -e "${GREEN}✓${RESET}"
    
    # Network interfaces
    echo -ne "${DIM}[7/8]${RESET} Detecting network interfaces... "
    local interfaces=$(ip -br addr | awk '{print $1}' | tr '\n' ',' | sed 's/,$//')
    local active_connections=$(ss -tun | wc -l)
    echo -e "${GREEN}✓${RESET}"
    
    # Top processes
    echo -ne "${DIM}[8/8]${RESET} Capturing top processes... "
    local top_procs=$(ps aux --sort=-%cpu | head -11 | tail -10)
    echo -e "${GREEN}✓${RESET}"
    
    # Calculate health score
    local health_score=100
    local warnings=""
    
    # CPU check
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        health_score=$((health_score - 15))
        warnings="${warnings}High CPU usage (${cpu_usage}%)|"
    elif (( $(echo "$cpu_usage > 60" | bc -l) )); then
        health_score=$((health_score - 5))
    fi
    
    # RAM check
    if (( $(echo "$ram_percent > 85" | bc -l) )); then
        health_score=$((health_score - 20))
        warnings="${warnings}Critical RAM usage (${ram_percent}%)|"
    elif (( $(echo "$ram_percent > 70" | bc -l) )); then
        health_score=$((health_score - 10))
        warnings="${warnings}High RAM usage (${ram_percent}%)|"
    fi
    
    # Disk check
    if (( disk_percent > 90 )); then
        health_score=$((health_score - 25))
        warnings="${warnings}Critical disk usage (${disk_percent}%)|"
    elif (( disk_percent > 75 )); then
        health_score=$((health_score - 10))
        warnings="${warnings}High disk usage (${disk_percent}%)|"
    fi
    
    # Swap check
    if (( $(echo "$swap_percent > 50" | bc -l) )); then
        health_score=$((health_score - 10))
        warnings="${warnings}High swap usage (${swap_percent}%)|"
    fi
    
    # Load average check
    local load_1min=$(echo "$load_avg" | awk '{print $1}' | tr -d ',')
    if (( $(echo "$load_1min > $cpu_cores * 2" | bc -l) )); then
        health_score=$((health_score - 15))
        warnings="${warnings}High load average ($load_1min)|"
    fi
    
    [[ $health_score -lt 0 ]] && health_score=0
    
    # Store in database
    local scan_id=$(sqlite3 "$SPIDER_DB" <<EOF
INSERT INTO system_scans (
    hostname, os_info, kernel, uptime, load_avg,
    cpu_usage, ram_total, ram_used, ram_free,
    swap_total, swap_used, disk_usage,
    health_score, warnings
) VALUES (
    '$hostname', '$os_info', '$kernel', '$uptime', '$load_avg',
    $cpu_usage, $ram_total, $ram_used, $ram_free,
    $swap_total, $swap_used, '${disk_total},${disk_used},${disk_free},${disk_percent}',
    $health_score, '${warnings%|}'
);
SELECT last_insert_rowid();
EOF
)
    
    # Store top processes
    while IFS= read -r line; do
        local pid=$(echo "$line" | awk '{print $2}')
        local user=$(echo "$line" | awk '{print $1}')
        local cpu=$(echo "$line" | awk '{print $3}')
        local mem=$(echo "$line" | awk '{print $4}')
        local cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}' | sed "s/'/''/g")
        
        sqlite3 "$SPIDER_DB" "INSERT INTO processes (scan_id, pid, user, cpu, mem, command) VALUES ($scan_id, $pid, '$user', $cpu, $mem, '$cmd');"
    done <<< "$top_procs"
    
    # Display report
    display_system_report "$scan_id" "$hostname" "$os_info" "$kernel" "$uptime" "$boot_time" \
        "$load_avg" "$cpu_usage" "$cpu_cores" "$ram_total" "$ram_used" "$ram_free" "$ram_percent" \
        "$swap_total" "$swap_used" "$swap_percent" "$disk_total" "$disk_used" "$disk_free" "$disk_percent" \
        "$interfaces" "$active_connections" "$health_score" "$warnings" "$top_procs"
}

display_system_report() {
    local scan_id=$1 hostname=$2 os_info=$3 kernel=$4 uptime=$5 boot_time=$6
    local load_avg=$7 cpu_usage=$8 cpu_cores=$9 ram_total=${10} ram_used=${11} ram_free=${12} ram_percent=${13}
    local swap_total=${14} swap_used=${15} swap_percent=${16}
    local disk_total=${17} disk_used=${18} disk_free=${19} disk_percent=${20}
    local interfaces=${21} active_connections=${22} health_score=${23} warnings=${24}
    local top_procs=${25}
    
    echo -e "\n${BOLD}${BRIGHT_MAGENTA}═══════════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${BRIGHT_MAGENTA}                    SYSTEM SCAN REPORT #${scan_id}${RESET}"
    echo -e "${BOLD}${BRIGHT_MAGENTA}═══════════════════════════════════════════════════════════════${RESET}\n"
    
    # Health Score
    local score_color=$BRIGHT_RED
    local score_status="CRITICAL"
    if [[ $health_score -ge 80 ]]; then
        score_color=$BRIGHT_GREEN
        score_status="HEALTHY"
    elif [[ $health_score -ge 60 ]]; then
        score_color=$BRIGHT_YELLOW
        score_status="WARNING"
    elif [[ $health_score -ge 40 ]]; then
        score_color=$YELLOW
        score_status="DEGRADED"
    fi
    
    echo -e "${BOLD}HEALTH SCORE:${RESET} ${score_color}${BOLD}${health_score}/100${RESET} ${score_color}[${score_status}]${RESET}"
    draw_bar "$health_score" 100 50 "$score_color"
    echo ""
    
    # Warnings
    if [[ -n "$warnings" ]]; then
        echo -e "${BOLD}${BRIGHT_RED}WARNINGS:${RESET}"
        IFS='|' read -ra WARN_ARRAY <<< "$warnings"
        for warn in "${WARN_ARRAY[@]}"; do
            [[ -n "$warn" ]] && echo -e "   ${BRIGHT_RED}•${RESET} $warn"
        done
        echo ""
    fi
    
    # Real-time live view
    echo -e "${BOLD}${BRIGHT_RED}REAL-TIME SYSTEM MONITOR${RESET} ${DIM}(press 'q' to quit)${RESET}"
    # hide cursor
    tput civis 2>/dev/null || true

    local stop=0
    trap 'stop=1' SIGINT SIGTERM

    while [[ $stop -eq 0 ]]; do
        # Gather live metrics
        local uptime_live=$(uptime -p 2>/dev/null)
        local load_avg_live=$(uptime | awk -F'load average:' '{print $2}' | xargs)
        local cpu_usage_live=$(top -bn1 | awk -F'id,' -v OFS='' 'NR==1{ sub(/.*, /,"",$1); getline; } { if ($0 ~ /Cpu/){gsub("%","",$0); split($0,a,","); for(i in a){ if (a[i] ~ /ni|us|sy/){} } } } END{ cmd="top -bn1 | grep Cpu"; cmd | getline; close(cmd) }' 2>/dev/null)
        # fallback cpu parse
        cpu_usage_live=$(top -bn1 | grep "Cpu(s)" | awk '{usage=100-$8; if (usage=="") usage=0; printf "%.1f", usage}')
        local cpu_cores_live=$(nproc 2>/dev/null || echo "$cpu_cores")

        local ram_total_live=$(free -m | awk 'NR==2{print $2}')
        local ram_used_live=$(free -m | awk 'NR==2{print $3}')
        local ram_free_live=$(free -m | awk 'NR==2{print $4}')
        local ram_percent_live=$(awk "BEGIN{ if($ram_total_live>0) printf \"%.1f\", ($ram_used_live/$ram_total_live)*100; else print 0 }")

        local swap_total_live=$(free -m | awk 'NR==3{print $2}')
        local swap_used_live=$(free -m | awk 'NR==3{print $3}')
        local swap_percent_live=0
        if [[ $swap_total_live -gt 0 ]]; then
            swap_percent_live=$(awk "BEGIN{printf \"%.1f\", ($swap_used_live/$swap_total_live)*100}")
        fi

        local disk_data_live=$(df -h / | awk 'NR==2{print $2","$3","$4","$5}')
        IFS=',' read -r disk_total_live disk_used_live disk_free_live disk_percent_live <<< "$disk_data_live"
        disk_percent_live=${disk_percent_live%\%}

        local interfaces_live=$(ip -br addr 2>/dev/null | awk '{print $1}' | tr '\n' ',' | sed 's/,$//')
        local active_connections_live=$(ss -tun 2>/dev/null | wc -l)
        local top_procs_live=$(ps aux --sort=-%cpu | head -11 | tail -10)

        # Render
        clear
        echo -e "${BOLD}${BRIGHT_RED}REAL-TIME SYSTEM MONITOR${RESET} ${DIM}(press 'q' to quit)${RESET}"
        echo ""

        echo -e "${BOLD}${BRIGHT_RED}SYSTEM INFORMATION${RESET}"
        echo -e "   ${DIM}Hostname:${RESET}     $hostname"
        echo -e "   ${DIM}OS:${RESET}           $os_info"
        echo -e "   ${DIM}Kernel:${RESET}       $kernel"
        echo -e "   ${DIM}Uptime:${RESET}       $uptime_live"
        echo -e "   ${DIM}Load Avg:${RESET}     $load_avg_live"
        echo ""

        echo -e "${BOLD}${BRIGHT_RED}CPU${RESET}"
        echo -e "   ${DIM}Cores:${RESET}        $cpu_cores_live"
        echo -e "   ${DIM}Usage:${RESET}        ${cpu_usage_live}%"
        draw_bar "$cpu_usage_live" 100 30 "$BRIGHT_BLUE"
        echo ""

        echo -e "${BOLD}${BRIGHT_RED}MEMORY${RESET}"
        echo -e "   ${DIM}Total:${RESET}        ${ram_total_live}MB"
        echo -e "   ${DIM}Used:${RESET}         ${ram_used_live}MB (${ram_percent_live}%)"
        echo -e "   ${DIM}Free:${RESET}         ${ram_free_live}MB"
        draw_bar "$ram_percent_live" 100 30 "$BRIGHT_GREEN"
        echo ""

        if [[ $swap_total_live -gt 0 ]]; then
            echo -e "${BOLD}${BRIGHT_RED}SWAP${RESET}"
            echo -e "   ${DIM}Total:${RESET}        ${swap_total_live}MB"
            echo -e "   ${DIM}Used:${RESET}         ${swap_used_live}MB (${swap_percent_live}%)"
            draw_bar "$swap_percent_live" 100 30 "$YELLOW"
            echo ""
        fi

        echo -e "${BOLD}${BRIGHT_RED}DISK (/)${RESET}"
        echo -e "   ${DIM}Total:${RESET}        $disk_total_live"
        echo -e "   ${DIM}Used:${RESET}         $disk_used_live (${disk_percent_live}%)"
        echo -e "   ${DIM}Free:${RESET}         $disk_free_live"
        draw_bar "$disk_percent_live" 100 30 "$MAGENTA"
        echo ""

        echo -e "${BOLD}${BRIGHT_RED}NETWORK${RESET}"
        echo -e "   ${DIM}Interfaces:${RESET}   $interfaces_live"
        echo -e "   ${DIM}Connections:${RESET}  $active_connections_live"
        echo ""

        echo -e "${BOLD}${BRIGHT_RED}TOP 10 PROCESSES (by CPU)${RESET}"
        echo -e "   ${DIM}PID       USER          %CPU   %MEM   COMMAND${RESET}"
        while IFS= read -r line; do
            local pid=$(echo "$line" | awk '{print $2}')
            local user=$(echo "$line" | awk '{print $1}')
            local cpu=$(echo "$line" | awk '{print $3}')
            local mem=$(echo "$line" | awk '{print $4}')
            local cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}' | cut -c1-40)
            printf "   %-9s %-13s %5s  %5s  %s\n" "$pid" "$user" "$cpu" "$mem" "$cmd"
        done <<< "$top_procs_live"

        echo ""
        echo -e "${DIM}Press 'q' to exit live view...${RESET}"

        # wait for key or timeout (2s)
        read -t 2 -n 1 key 2>/dev/null || key=""
        if [[ $key == "q" || $key == "Q" ]]; then
            break
        fi
    done

    # restore cursor
    tput cnorm 2>/dev/null || true

    echo -e "\n${BOLD}${BRIGHT_MAGENTA}═══════════════════════════════════════════════════════════════${RESET}"
    echo -e "Scan stored in database with ID: ${DIM}$scan_id${RESET}"
    echo -e "Database location: ${DIM}$SPIDER_DB${RESET}"
}

draw_bar() {
    local value=$1
    local max=$2
    local width=$3
    local color=$4
    
    local filled=$(awk "BEGIN {printf \"%.0f\", ($value/$max)*$width}")
    local empty=$((width - filled))
    
    echo -n "   ["
    for ((i=0; i<filled; i++)); do
        echo -ne "${color}█${RESET}"
    done
    for ((i=0; i<empty; i++)); do
        echo -ne "${DIM}░${RESET}"
    done
    echo "]"
}

# ============================================================================
# MAIN LOOP
# ============================================================================
main() { 
        clear
        generate_info
        init_database
        collect_system_info
        echo -e "🕸️    ${BOLD}${BRIGHT_RED}YOUR SPIDER ATE: ${RESET}Press Enter to continue..."
        read -r
}

main