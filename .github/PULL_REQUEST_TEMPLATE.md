# Pull Request

## Summary

<!-- One or two sentences on what this PR changes and why. -->

## Type of change

- [ ] Bug fix
- [ ] New tool module under `lib/modules/`
- [ ] Improvement to an existing module
- [ ] Refactor / cleanup in `lib/core.sh`, `lib/installer.sh` or `lib/ui.sh`
- [ ] Documentation only
- [ ] CI / repo hygiene

## Checklist

- [ ] `bash -n` passes on every modified `*.sh`
- [ ] `shellcheck --severity=warning -e SC1091 -e SC2034 <files>` passes
      (or the CI job is green on this branch)
- [ ] If a new tool was added: a corresponding entry was added to the
      menu in `lib/ui.sh` and the dispatcher in `feedyourspider.sh`
- [ ] If installer behavior changed: `install_package` / `ensure_command`
      mappings cover apt, dnf, pacman, and brew at minimum
- [ ] No French strings, comments, or variable names introduced
- [ ] No `Co-Authored-By: Claude` line in any commit message

## Manual test

<!-- What did you actually run? Paste the menu choices / commands and a
short transcript or screenshot if relevant. -->
