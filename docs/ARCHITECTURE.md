# Architecture

FeedYourSpider is a small set of bash scripts. There are no external
runtime dependencies beyond bash itself and the tools each module
wraps.

## Layout

```
.
├── feedyourspider.sh            Entry point. Sources lib/ and runs the menu loop.
├── lib/
│   ├── core.sh                  TTY-aware colors, constants, output-dir helpers.
│   ├── installer.sh             Logging, prompts, package-manager dispatcher.
│   ├── ui.sh                    ASCII banner, title screen, side-by-side renderer.
│   └── modules/
│       ├── nmap.sh
│       ├── netcat.sh
│       ├── tcpdump.sh
│       ├── tshark.sh
│       ├── hping3.sh
│       ├── arpscan.sh
│       ├── masscan.sh
│       ├── nikto.sh
│       ├── dnsenum.sh
│       └── whatweb.sh
├── docs/
│   ├── ARCHITECTURE.md          (this file)
│   └── ADDING_A_TOOL.md
└── .github/                     Issue templates, PR template, CI workflow.
```

## Boot sequence

1. `feedyourspider.sh` sets `set -uo pipefail` and resolves its own
   directory via `BASH_SOURCE[0]`. (`set -e` is intentionally not used:
   the interactive menu loop relies on individual commands being allowed
   to fail and return to the prompt.)
2. It sources `lib/core.sh`, `lib/installer.sh`, `lib/ui.sh`.
3. It sources every `lib/modules/*.sh`. Each module guards against
   double-sourcing with a `FEEDYOURSPIDER_MOD_<NAME>_LOADED` sentinel.
4. `display_title_middle_screen` paints a centered title, then
   `main_loop` enters an infinite loop:
   - `clear`
   - `display_banner_with_menu` (ASCII art + menu, side by side)
   - read one numeric choice
   - `dispatch_choice` routes it to `<tool>_run` (or `exit 0` for `[0]`)
   - `press_enter_to_continue` waits before the next iteration

## Cross-cutting helpers

These live in `lib/core.sh` and `lib/installer.sh` and are used by
every module:

| Helper                     | Purpose                                                                  |
|----------------------------|--------------------------------------------------------------------------|
| `log_step "msg"`           | Bold magenta `==>` line, used to announce what is about to happen.       |
| `log_info "msg"`           | Dim text for ancillary detail (paths, hints).                            |
| `log_warn "msg"`           | Bright red `!` line, to stderr.                                          |
| `log_error "msg"`          | Bright red `x` line, to stderr.                                          |
| `log_success "msg"`        | Bright green `ok` line.                                                  |
| `prompt_value "Label" "default"` | Read a free-form value. Empty input falls back to the default.     |
| `prompt_choice "Title" a b c…`   | Render a numbered list and read the chosen number.                 |
| `prompt_yesno "Question"`  | Default-yes y/n prompt.                                                  |
| `detect_package_manager`   | Echoes one of `brew apt dnf yum pacman zypper apk unknown`.              |
| `install_package "<mapping>" <fallback>` | Runs `sudo <pm> install <pkg>` with the mapping for that pm.|
| `ensure_command <bin> "<mapping>" <fallback>` | If `<bin>` is missing, calls `install_package`.            |
| `fys_outdir <tool>`        | Returns (and creates) `$FEEDYOURSPIDER_OUTPUT_ROOT/feedyourspider_<tool>`. |
| `fys_timestamp`            | `YYYYMMDD_HHMMSS`.                                                       |
| `fys_safe_name <str>`      | Replaces every char not in `[A-Za-z0-9._-]` with `_`. Use for filenames. |

## Color handling

`lib/core.sh` exports color variables only when `stdout` is a TTY. When
the script is piped or redirected, every color variable is set to the
empty string, so logs stay clean.

## Output directories

Per-tool output is written under `$FEEDYOURSPIDER_OUTPUT_ROOT` (defaults
to `$HOME`). Each module computes a directory via `fys_outdir <tool>`
and a timestamped base via `fys_timestamp`.

To redirect every tool's output to a single sandbox directory, set the
env var before launching:

```bash
FEEDYOURSPIDER_OUTPUT_ROOT="/tmp/fys" ./feedyourspider.sh
```

## Adding tools

See [ADDING_A_TOOL.md](ADDING_A_TOOL.md).
