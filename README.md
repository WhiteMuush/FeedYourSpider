
![TITLE](https://github.com/user-attachments/assets/9dc512ae-4349-4b13-b5ff-6e227ef8d26d)

Interactive toolkit launcher for common network tools (nmap, netcat, tcpdump, tshark, hping3, arp-scan, masscan, nikto, dnsenum, whatweb).

This repository contains `feedyourspider.sh`, a small, terminal-first menu that helps run common reconnaissance and capture tools, saves outputs to timestamped directories, and attempts to install missing tools automatically on many platforms.

## Features
- Colorful ASCII banner and a menu-driven interface.
- Quick access to common network utilities with useful presets.
- Saves results into per-tool timestamped directories under $HOME.
- Attempts to install missing tools (supports apt, dnf, yum, pacman, zypper, apk, Homebrew).
- Lightweight, POSIX-friendly Bash with safe quoting and minimal dependencies.

## Requirements
- Bash (sh compatible)
- One or more of the network tools below depending on what you want to run:
    - [Nmap](https://nmap.org/)
    - [Netcat / Ncat (nc)](https://nmap.org/ncat/)
    - [tcpdump](https://www.tcpdump.org/)
    - [TShark (Wireshark)](https://www.wireshark.org/docs/man-pages/tshark.html)
    - [hping3](http://www.hping.org/)
    - [arp-scan](https://github.com/royhills/arp-scan)
    - [masscan](https://github.com/robertdavidgraham/masscan)
    - [Nikto](https://github.com/sullo/nikto)
    - [dnsenum](https://github.com/fwaeytens/dnsenum)
    - [WhatWeb](https://github.com/urbanadventurer/WhatWeb)
- sudo for installing packages and for some capture or raw-socket operations

## Installation
1. Make the script executable:
     chmod +x feedyourspider.sh
2. Run:
     ./feedyourspider.sh

The script will try to install missing tools automatically when you select a menu option; if automatic install fails, install the tool manually and re-run.

## Usage
- Launch the script and pick a numbered menu option.
- Follow prompts for targets, interfaces, ports, or custom args.
- Outputs are saved under directories like:
    - $HOME/feedyourspider_nmap
    - $HOME/feedyourspider_tcpdump
    - $HOME/feedyourspider_netcat
    - etc.
- Use Ctrl+C to stop live captures.

Example: run a quick nmap scan
1. Start script.
2. Choose `1` (Nmap).
3. Provide a target (IP/CIDR) and select a scan profile.

https://github.com/user-attachments/assets/b99f1de3-5ecd-4964-b53c-7a4999e15855

## Notes & Safety
- Use only on systems and networks where you have explicit authorization.
- Some operations require elevated privileges (sudo) or may trigger security alerts.
- The script is intended as a convenience wrapper, review commands before running, especially with custom args.

## Contributing
PRs and issues are welcome. Keep changes minimal and shell-lint friendly. Prefer POSIX/Bash-compatible constructs.

## License
100% FREE, no license required.

## Disclaimer
Provided as-is. The author is not responsible for misuse. Use responsibly and legally.
