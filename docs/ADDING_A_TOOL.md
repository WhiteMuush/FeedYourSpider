# Adding a new tool

A typical tool module is between 20 and 50 lines. The four steps below
are everything you need. As an example we add `gobuster`.

## 1. Create the module file

`lib/modules/gobuster.sh`:

```bash
#!/usr/bin/env bash
# lib/modules/gobuster.sh — Gobuster module.

if [[ -n "${FEEDYOURSPIDER_MOD_GOBUSTER_LOADED:-}" ]]; then
    return 0
fi
FEEDYOURSPIDER_MOD_GOBUSTER_LOADED=1

gobuster_run() {
    ensure_command gobuster \
        "apt=gobuster dnf=gobuster pacman=gobuster brew=gobuster" \
        "gobuster" || return 0

    log_step "Launching Gobuster"
    local outdir
    outdir=$(fys_outdir gobuster)

    local url wordlist outbase
    url=$(prompt_value "Target URL (e.g. http://example.com)")
    wordlist=$(prompt_value "Wordlist" "/usr/share/wordlists/dirb/common.txt")
    outbase="${outdir}/dir_$(fys_timestamp).txt"

    log_step "Running gobuster dir on ${url}"
    log_info "Saving to ${outbase}"
    gobuster dir -u "$url" -w "$wordlist" -o "$outbase"
}
```

That's the whole tool. No installer boilerplate to copy: `ensure_command`
takes care of detecting the package manager and running `sudo <pm>
install <pkg>` with the right package name for the user's system.

## 2. Source the module in the entry point

`feedyourspider.sh`, in the source-block at the top:

```bash
# shellcheck source=lib/modules/gobuster.sh
source "${MOD_DIR}/gobuster.sh"
```

## 3. Wire the dispatcher

`feedyourspider.sh`, in `dispatch_choice`:

```bash
case "$1" in
    ...
    10) whatweb_run  ;;
    11) gobuster_run ;;   # new
    0)  log_step "Exiting..."; exit 0 ;;
    *)  log_error "Invalid choice. Please try again." ;;
esac
```

## 4. Add the menu line

`lib/ui.sh`, in `generate_menu`:

```bash
"${BOLD}${BRIGHT_MAGENTA}#${RESET}    ${BRIGHT_RED}[10]${RESET} Whatweb"
"${BOLD}${BRIGHT_MAGENTA}#${RESET}    ${BRIGHT_RED}[11]${RESET} Gobuster"   # new
```

That's it.

## Don't / Do

| Don't                                                  | Do                                                              |
|--------------------------------------------------------|-----------------------------------------------------------------|
| `echo -e "${RED}error${RESET}"`                        | `log_error "error"`                                             |
| `read -p "Target: " target`                            | `target=$(prompt_value "Target")`                               |
| Copy-paste the `command -v / apt-get / dnf / brew` block | `ensure_command <bin> "<mapping>" <fallback>`                 |
| `mkdir -p "$HOME/feedyourspider_foo"` then concatenate timestamps by hand | `outdir=$(fys_outdir foo); outbase="${outdir}/x_$(fys_timestamp).log"` |
| `IFS=' ' read -r -a args <<< "$str"` (or older variants)  | `read -ra args <<<"$str"`                                       |
| `arr=($(some_cmd))`                                    | `mapfile -t arr < <(some_cmd)`                                  |
| `tput setaf 1` outside of `lib/core.sh`                | Use the pre-defined `RED`, `BRIGHT_RED`, etc. (TTY-guarded)     |
| Hard-coded French strings                              | English in code, comments, prompts, log messages, docs          |
| `set -e` inside a module                               | Let the menu loop handle non-zero exits                         |

## Validation

Before opening your PR:

```bash
bash -n lib/modules/gobuster.sh
bash -c '
  source lib/core.sh
  source lib/installer.sh
  source lib/ui.sh
  source lib/modules/gobuster.sh
  declare -F gobuster_run
'
shellcheck --severity=warning -e SC1091 -e SC2034 lib/modules/gobuster.sh
```
