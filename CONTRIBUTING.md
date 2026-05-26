# Contributing to FeedYourSpider

Thanks for considering a contribution. FeedYourSpider is intentionally
small: an interactive menu around well-known network and recon tools.
Most contributions are either a new tool module or a bug fix in an
existing one.

## Quick start (local setup)

```bash
git clone https://github.com/WhiteMuush/FeedYourSpider.git
cd FeedYourSpider
chmod +x feedyourspider.sh
./feedyourspider.sh
```

No build step. The script sources every file under `lib/` and dispatches
menu choices to the corresponding module.

## Repository layout

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full layout and
boot sequence. In short:

```
feedyourspider.sh       Thin entry point. Sources lib/ and runs the menu loop.
lib/core.sh             Colors (TTY-aware), constants, output-dir helpers.
lib/installer.sh        Logging, prompts, ensure_command, install_package.
lib/ui.sh               ASCII banner, title screen, side-by-side renderer.
lib/modules/<tool>.sh   One file per tool. Exposes <tool>_run().
```

## Conventions

- Shebang: `#!/usr/bin/env bash`.
- Strict-ish mode: `set -uo pipefail` at the entry point only. Modules
  must not enable `set -e` — the interactive menu loop relies on
  non-zero exits to gracefully return to the prompt.
- Quote every variable: `"${var}"`, `"${arr[@]}"`.
- Functions are `snake_case` and prefixed by the module (e.g.
  `nmap_run`, `_netcat_listen`). Leading `_` marks a helper that is
  only used inside its own module.
- Globals "private" to the project use the `FEEDYOURSPIDER_*` prefix.
- Use the logging helpers (`log_step`, `log_info`, `log_warn`,
  `log_error`, `log_success`) instead of raw `echo -e` with color
  variables.
- Use `prompt_value`, `prompt_choice`, `prompt_yesno` for user input.
- Use `ensure_command` to install missing tools rather than copying
  package-manager boilerplate.
- All code, comments, log messages, and prompts are in **English**.
  Non-English strings will be rejected at review.
- No emojis in code or docs unless they are already part of an upstream
  banner being preserved verbatim.

## Adding a new tool

The recipe is documented step by step in
[docs/ADDING_A_TOOL.md](docs/ADDING_A_TOOL.md). The short version:

1. Create `lib/modules/<tool>.sh` exposing `<tool>_run()`.
2. Source it in `feedyourspider.sh`.
3. Add a `case` arm in `dispatch_choice`.
4. Add a menu line in `lib/ui.sh` (`generate_menu`).

## Before opening a PR

Run locally:

```bash
# Syntax check
for f in lib/core.sh lib/installer.sh lib/ui.sh lib/modules/*.sh feedyourspider.sh; do
  bash -n "$f" || exit 1
done

# Smoke test: every expected function must be defined after sourcing
bash -c '
  source lib/core.sh
  source lib/installer.sh
  source lib/ui.sh
  for m in lib/modules/*.sh; do source "$m"; done
  declare -F <your_new_function>
'

# Optional but recommended
shellcheck --severity=warning -e SC1091 -e SC2034 \
  feedyourspider.sh lib/core.sh lib/installer.sh lib/ui.sh lib/modules/*.sh
```

The CI runs the same three checks. PRs whose CI is red will not be
merged until the issues are addressed.

## Commit messages

Follow the [Conventional Commits](https://www.conventionalcommits.org)
convention used in the existing history:

```
feat: add gobuster module
fix(netcat): handle BSD nc -p variant
refactor(installer): collapse pm dispatch
docs(adding_a_tool): clarify menu wiring
ci: bump shellcheck action
```

Do not add `Co-Authored-By` lines that credit AI assistants. Human
contributors only.

## Code of Conduct

By participating you agree to abide by the [Code of Conduct](CODE_OF_CONDUCT.md).

## Security

For vulnerabilities, please follow [SECURITY.md](SECURITY.md) instead of
opening a public issue.
