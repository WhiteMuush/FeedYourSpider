# FeedYourSpider

![FeedYourSpider](https://github.com/user-attachments/assets/9dc512ae-4349-4b13-b5ff-6e227ef8d26d)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![CI](https://github.com/WhiteMuush/FeedYourSpider/actions/workflows/ci.yml/badge.svg)](https://github.com/WhiteMuush/FeedYourSpider/actions/workflows/ci.yml)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](docs/CONTRIBUTING.md)

**FeedYourSpider** is a menu-driven launcher for the network and recon tools you
reach for daily. Pick one, it installs the tool if it is missing, prompts for
the target or interface, runs it with sensible presets and saves the output to a
timestamped folder.

## Quick start

```bash
git clone https://github.com/WhiteMuush/FeedYourSpider.git
cd FeedYourSpider && chmod +x feedyourspider.sh
./feedyourspider.sh
```

Pick a numbered item. If the tool is not on `PATH`, FeedYourSpider offers to
install it, on apt, dnf, yum, pacman, zypper, apk or Homebrew, so it works
natively across Linux and macOS. Output lands in `$HOME/feedyourspider_<tool>/`
(override the root with `FEEDYOURSPIDER_OUTPUT_ROOT`). `Ctrl+C` stops a live
capture.

## Tools

| Area | Tools |
|---|---|
| **Scan** | [Nmap](https://nmap.org/), [masscan](https://github.com/robertdavidgraham/masscan), [arp-scan](https://github.com/royhills/arp-scan) |
| **Capture** | [tcpdump](https://www.tcpdump.org/), [TShark](https://www.wireshark.org/docs/man-pages/tshark.html) |
| **Connect / craft** | [Ncat / Netcat](https://nmap.org/ncat/), [hping3](http://www.hping.org/) |
| **Web / DNS** | [Nikto](https://github.com/sullo/nikto), [WhatWeb](https://github.com/urbanadventurer/WhatWeb), [dnsenum](https://github.com/fwaeytens/dnsenum) |

Each tool is one small file under `lib/modules/`; adding one is a 4-step recipe
in [docs/ADDING_A_TOOL.md](docs/ADDING_A_TOOL.md).

## Demo

https://github.com/user-attachments/assets/b99f1de3-5ecd-4964-b53c-7a4999e15855

## Project layout

```
feedyourspider.sh    thin orchestrator: sources lib/ and runs the menu loop
lib/
  core.sh            TTY-aware colors, constants, output helpers
  installer.sh       logging, prompts, ensure_command / install_package
  ui.sh              ASCII banner, title screen, side-by-side renderer
  modules/<tool>.sh  one file per tool, exposes <tool>_run()
docs/                ARCHITECTURE, ADDING_A_TOOL, CONTRIBUTING, SECURITY, CHANGELOG
```

## Requirements

Bash 4+, and `sudo` for some captures, raw-socket scans and automatic installs.
The wrapped tools are pulled on demand, install only what you use.

## Safety

Use only on systems and networks you are authorized to test. Some operations
need elevated privileges or may trigger security alerts. This is a convenience
wrapper, review commands before running, especially with custom arguments.

## Contributing

PRs and issues welcome. Start with [CONTRIBUTING.md](docs/CONTRIBUTING.md) for
conventions, the checklist and the commands CI runs. Adding a tool is around 30
lines, see [docs/ADDING_A_TOOL.md](docs/ADDING_A_TOOL.md).

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).

## Disclaimer

Provided as-is. The author is not responsible for misuse. Use responsibly and
legally.
