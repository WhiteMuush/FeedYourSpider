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
        "${BOLD}${BRIGHT_RED}   ____ ____ ____ ___     _   _ ____ _  _ ____    ____ ___  _ ___  ____ ____ ${RESET}"
        "${BOLD}${BRIGHT_RED}   |___ |___ |___ |  \\     \\_/  |  | |  | |__/    [__  |__] | |  \\ |___ |__/ ${RESET}"
        "${BOLD}${BRIGHT_RED}   |    |___ |___ |__/      |   |__| |__| |  \\    ___] |    | |__/ |___ |  \\ ${RESET}"
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

# Inline bar drawing (no newline)
draw_bar_inline() {
    local value=$1
    local max=$2
    local width=$3
    local color=$4
    
    local filled=$(awk "BEGIN {printf \"%.0f\", ($value/$max)*$width}")
    local empty=$((width - filled))
    
    printf "["
    for ((i=0; i<filled; i++)); do
        printf "${color}█${RESET}"
    done
    for ((i=0; i<empty; i++)); do
        printf "${DIM}░${RESET}"
    done
    printf "]"
}

display_system_report() {
    local scan_id=$1 hostname=$2 os_info=$3 kernel=$4 uptime=$5 boot_time=$6
    local load_avg=$7 cpu_usage=$8 cpu_cores=$9 ram_total=${10} ram_used=${11} ram_free=${12} ram_percent=${13}
    local swap_total=${14} swap_used=${15} swap_percent=${16}
    local disk_total=${17} disk_used=${18} disk_free=${19} disk_percent=${20}
    local interfaces=${21} active_connections=${22} health_score=${23} warnings=${24}
    local top_procs=${25}

    clear
    tput civis 2>/dev/null || true
    generate_info
    # Header
    echo -e "${BOLD}${BRIGHT_RED}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${BRIGHT_RED}║                      🕷️  REAL-TIME SYSTEM MONITOR                          ║${RESET}"
    echo -e "${BOLD}${BRIGHT_RED}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${BOLD}${BRIGHT_RED}║${RESET} Scan ID: ${BRIGHT_MAGENTA}#${scan_id}${RESET}             ${DIM}Press 'q' to quit and return to menu${RESET}              ${BOLD}${BRIGHT_RED}║${RESET}"
    echo -e "${BOLD}${BRIGHT_RED}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    # System Info (static)
    echo -e "${BOLD}${BRIGHT_CYAN}- SYSTEM INFORMATION${RESET}"
    echo -e "   ${DIM}Hostname:${RESET}  $hostname"
    echo -e "   ${DIM}OS:${RESET}        $os_info"
    echo -e "   ${DIM}Kernel:${RESET}    $kernel"
    echo -e "   ${DIM}Uptime:${RESET}    $uptime"
    echo ""
    
    # Save cursor position for dynamic updates
    local cpu_line=$(tput lines)
    tput sc
    
    # Reserve space for dynamic content
    echo -e "${BOLD}${BRIGHT_CYAN}- CPU${RESET}"
    echo "   Usage:                                                                      "
    echo ""
    echo -e "${BOLD}${BRIGHT_CYAN}- MEMORY${RESET}"
    echo "   RAM:                                                                        "
    echo ""
    echo -e "${BOLD}${BRIGHT_CYAN}- DISK${RESET}"
    echo "   Usage:                                                                      "
    echo ""
    echo -e "${BOLD}${BRIGHT_CYAN}- NETWORK${RESET}"
    echo "   Active Connections:                                                         "
    echo "   Throughput:                                                                 "
    echo ""
    echo -e "${BOLD}${BRIGHT_CYAN}- TOP 5 PROCESSES (by CPU)${RESET}"
    for i in {1..5}; do echo "                                                                                "; done
    
    # Calculate line positions
    local start_line=12
    local cpu_val_line=$((start_line + 7))
    local mem_val_line=$((start_line + 10))
    local disk_val_line=$((start_line + 13))
    local net_conn_line=$((start_line + 16))
    local net_thr_line=$((start_line + 17))
    local proc_start_line=$((start_line + 20))
    
    # Initialize CPU counters
    read -r _ cpu_user cpu_nice cpu_system cpu_idle cpu_iowait cpu_irq cpu_softirq cpu_steal _ < /proc/stat
    local prev_idle=$((cpu_idle + cpu_iowait))
    local prev_non_idle=$((cpu_user + cpu_nice + cpu_system + cpu_irq + cpu_softirq + cpu_steal))
    local prev_total=$((prev_idle + prev_non_idle))
    
    # Initialize network counters
    local prev_rx=0 prev_tx=0
    while read -r line; do
        iface=$(echo "$line" | awk -F: '{print $1}' | xargs)
        if [[ -z "$iface" || "$iface" == "lo" ]]; then continue; fi
        vals=$(echo "$line" | awk -F: '{print $2}')
        rx=$(echo $vals | awk '{print $1}')
        tx=$(echo $vals | awk '{print $9}')
        prev_rx=$((prev_rx + rx))
        prev_tx=$((prev_tx + tx))
    done < /proc/net/dev
    
    local interval=0.5
    local stop=0
    trap 'stop=1' SIGINT SIGTERM
    
    while [[ $stop -eq 0 ]]; do
        # CPU calculation
        read -r _ cpu_user cpu_nice cpu_system cpu_idle cpu_iowait cpu_irq cpu_softirq cpu_steal _ < /proc/stat
        local idle=$((cpu_idle + cpu_iowait))
        local non_idle=$((cpu_user + cpu_nice + cpu_system + cpu_irq + cpu_softirq + cpu_steal))
        local total=$((idle + non_idle))
        
        local total_diff=$((total - prev_total))
        local idle_diff=$((idle - prev_idle))
        local cpu_usage_live="0.0"
        if (( total_diff > 0 )); then
            cpu_usage_live=$(awk "BEGIN {printf \"%.1f\", (1 - $idle_diff / $total_diff) * 100}")
        fi
        
        prev_total=$total
        prev_idle=$idle
        
        # Memory
        local ram_total_live=$(free -m | awk 'NR==2{print $2}')
        local ram_used_live=$(free -m | awk 'NR==2{print $3}')
        local ram_percent_live=$(awk "BEGIN {printf \"%.1f\", ($ram_used_live/$ram_total_live)*100}")
        
        # Disk
        local disk_percent_live=$(df / | awk 'NR==2{gsub("%",""); print $5}')
        disk_percent_live=${disk_percent_live:-0}
        
        # Network
        local cur_rx=0 cur_tx=0
        while read -r line; do
            iface=$(echo "$line" | awk -F: '{print $1}' | xargs)
            if [[ -z "$iface" || "$iface" == "lo" ]]; then continue; fi
            vals=$(echo "$line" | awk -F: '{print $2}')
            rx=$(echo $vals | awk '{print $1}')
            tx=$(echo $vals | awk '{print $9}')
            cur_rx=$((cur_rx + rx))
            cur_tx=$((cur_tx + tx))
        done < /proc/net/dev
        
        local rx_rate=$((cur_rx - prev_rx))
        local tx_rate=$((cur_tx - prev_tx))
        local rx_rate_kbps=$(awk "BEGIN {printf \"%.1f\", ($rx_rate/$interval)/1024}")
        local tx_rate_kbps=$(awk "BEGIN {printf \"%.1f\", ($tx_rate/$interval)/1024}")
        
        prev_rx=$cur_rx
        prev_tx=$cur_tx
        
        # Active connections
        local active_connections_live=$(ss -tun 2>/dev/null | sed 1d | wc -l)
        
        # Top processes
        mapfile -t top_proc <<< "$(ps --no-headers -eo pid,user,%cpu,comm --sort=-%cpu | head -n 5)"
        
        # Update CPU
        tput cup $cpu_val_line 3
        printf "   CPU: %6s%% " "$cpu_usage_live"
        draw_bar_inline "$cpu_usage_live" 100 40 "$BRIGHT_BLUE"
        tput el
        
        # Update Memory
        tput cup $mem_val_line 3
        printf "   RAM: %6s%% (%s/%s MB) " "$ram_percent_live" "$ram_used_live" "$ram_total_live"
        draw_bar_inline "$ram_percent_live" 100 30 "$BRIGHT_GREEN"
        tput el
        
        # Update Disk
        tput cup $disk_val_line 3
        printf "   Disk: %3s%% (Free: %s) " "$disk_percent_live" "$disk_free"
        draw_bar_inline "$disk_percent_live" 100 30 "$BRIGHT_MAGENTA"
        tput el
        
        # Update Network
        tput cup $net_conn_line 3
        printf "   Active Connections: ${BRIGHT_YELLOW}%s${RESET}" "$active_connections_live"
        tput el
        
        tput cup $net_thr_line 3
        printf "   RX: ${BRIGHT_GREEN}%7s KB/s${RESET}  |  TX: ${BRIGHT_RED}%7s KB/s${RESET}" "$rx_rate_kbps" "$tx_rate_kbps"
        tput el
        
        # Update Top Processes
        for i in "${!top_proc[@]}"; do
            tput cup $((proc_start_line + i)) 0
            line=${top_proc[$i]}
            pid=$(echo "$line" | awk '{print $1}')
            user=$(echo "$line" | awk '{print $2}')
            cpu_p=$(echo "$line" | awk '{print $3}')
            cmd=$(echo "$line" | awk '{for (i=4;i<=NF;i++) printf $i " "; print ""}')
            printf "   ${DIM}PID:${RESET}%-6s ${DIM}CPU:${RESET}%5s%%  ${DIM}USER:${RESET}%-10s ${DIM}CMD:${RESET} %-35.35s" "$pid" "$cpu_p" "$user" "$cmd"
            tput el
        done
        
        # Check for quit key
        read -t $interval -n 1 key 2>/dev/null || key=""
        if [[ $key == "q" || $key == "Q" ]]; then
            stop=1
        fi
    done
    
    # Restore cursor and cleanup
    tput cnorm 2>/dev/null || true
    echo ""
    echo ""
    echo -e "${BOLD}${BRIGHT_MAGENTA}═══════════════════════════════════════════════════════════════${RESET}"
    echo -e "${DIM}Scan stored in database with ID: $scan_id${RESET}"
    echo -e "${DIM}Database location: $SPIDER_DB${RESET}"
}

# ============================================================================
# MAIN LOOP
# ============================================================================
main() { 
    clear
    init_database
    generate_info
    collect_system_info
    echo ""
    echo -e "${BOLD}${BRIGHT_RED}🕷️  YOUR SPIDER ATE:${RESET} Press Enter to continue..."
    read -r
    exit 0
}

main