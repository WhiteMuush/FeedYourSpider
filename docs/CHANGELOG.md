# Changelog

All notable changes to this project are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0]

### Added
- Input validation helpers in `lib/core.sh` (`fys_is_port`, `fys_is_port_spec`,
  `fys_is_ipv4`, `fys_is_hostname`, `fys_is_host`, `fys_is_cidr`,
  `fys_is_host_or_cidr`) and a `prompt_valid` wrapper that re-prompts on bad
  input. All modules now validate targets, ports, CIDR ranges and domains.
- Single tool registry (`FEEDYOURSPIDER_TOOLS` in `lib/core.sh`). The menu
  renderer and the dispatcher both derive from it, so adding a tool means
  editing one list.
- Bash 4+ guard at startup, with a clear message for stock macOS Bash 3.2.
- `run_custom_args` helper that deduplicates the per-module "custom args"
  branches.
- SIGINT trap so Ctrl+C interrupts the running tool and returns to the menu
  instead of exiting the launcher.
- Support for the `NO_COLOR` environment variable.

### Changed
- `ludeeus/action-shellcheck` is pinned to `2.0.0` in CI instead of `master`.
- Community health files (`CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`,
  `SECURITY.md`) moved into `.github/` to keep the repository root clean.

## [1.1.0]

### Changed
- Refactored the monolithic script into a modular layout: thin
  `feedyourspider.sh` entry point sourcing `lib/` and `lib/modules/`.
