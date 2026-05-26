# FeedYourSpider

![TITLE](https://github.com/user-attachments/assets/9dc512ae-4349-4b13-b5ff-6e227ef8d26d)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![CI](https://github.com/WhiteMuush/FeedYourSpider/actions/workflows/ci.yml/badge.svg)](https://github.com/WhiteMuush/FeedYourSpider/actions/workflows/ci.yml)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Interactive terminal launcher for common network and reconnaissance tools
(nmap, netcat, tcpdump, tshark, hping3, arp-scan, masscan, nikto, dnsenum,
whatweb). Saves outputs to timestamped directories and installs missing
tools automatically on most Linux distributions and macOS.

## Features

- Colorful ASCII banner and a menu-driven interface.
- Quick access to common network utilities with sensible presets.
- Per-tool, timestamped output directories under `$HOME`
  (override with `FEEDYOURSPIDER_OUTPUT_ROOT`).
- Automatic installation of missing tools across apt, dnf, yum, pacman,
  zypper, apk, and Homebrew via a single `ensure_command` helper.
- Modular layout: each tool is one ~30-line file under `lib/modules/`.
  Adding a new tool is a 4-step recipe documented in
  [docs/ADDING_A_TOOL.md](docs/ADDING_A_TOOL.md).

## Quick start

```bash
git clone https://github.com/WhiteMuush/FeedYourSpider.git
cd FeedYourSpider
chmod +x feedyourspider.sh
./feedyourspider.sh
```

Pick a numbered menu item. The script will offer to install the tool if
it isn't already on `PATH`, then prompt for targets, ports, interfaces,
or custom arguments.

Outputs land under `$HOME/feedyourspider_<tool>/`, for example:

- `$HOME/feedyourspider_nmap/`
- `$HOME/feedyourspider_tcpdump/`
- `$HOME/feedyourspider_netcat/`

Use `Ctrl+C` to stop a live capture.

## Project layout

```
feedyourspider.sh        Thin orchestrator: sources lib/ and runs the menu loop.
lib/
  core.sh                TTY-aware colors, constants, output helpers.
  installer.sh           Logging, prompts, ensure_command / install_package.
  ui.sh                  ASCII banner, title screen, side-by-side renderer.
  modules/<tool>.sh      One file per tool. Exposes <tool>_run().
docs/
  ARCHITECTURE.md        Boot sequence and cross-cutting helpers.
  ADDING_A_TOOL.md       Recipe for contributing a new tool.
.github/                 CI workflow, issue templates, PR template.
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full layout.

## Requirements

- Bash 4+
- `sudo` for some captures, raw-socket scans, and automatic installs
- One or more of the wrapped tools, on demand:
  [Nmap](https://nmap.org/),
  [Ncat / Netcat](https://nmap.org/ncat/),
  [tcpdump](https://www.tcpdump.org/),
  [TShark](https://www.wireshark.org/docs/man-pages/tshark.html),
  [hping3](http://www.hping.org/),
  [arp-scan](https://github.com/royhills/arp-scan),
  [masscan](https://github.com/robertdavidgraham/masscan),
  [Nikto](https://github.com/sullo/nikto),
  [dnsenum](https://github.com/fwaeytens/dnsenum),
  [WhatWeb](https://github.com/urbanadventurer/WhatWeb)

## Demo

https://github.com/user-attachments/assets/b99f1de3-5ecd-4964-b53c-7a4999e15855

## Safety

- Use only on systems and networks where you have explicit authorization.
- Some operations require elevated privileges or may trigger security alerts.
- The script is a convenience wrapper. Review commands before running,
  especially with custom args.

## Contributing

PRs and issues are welcome. Start with
[CONTRIBUTING.md](CONTRIBUTING.md) — it covers conventions,
the contribution checklist, and the validation commands the CI runs.

Adding a new tool? See [docs/ADDING_A_TOOL.md](docs/ADDING_A_TOOL.md);
the typical contribution is around 30 lines.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).

## Disclaimer

Provided as-is. The author is not responsible for misuse. Use responsibly
and legally.
