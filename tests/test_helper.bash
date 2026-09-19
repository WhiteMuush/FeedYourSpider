# tests/test_helper.bash - shared bootstrap for the FeedYourSpider bats suite.
FYS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
export FYS_ROOT
export TERM="${TERM:-xterm}"

load_libs() {
    # shellcheck source=../lib/core.sh
    source "${FYS_ROOT}/lib/core.sh"
    # shellcheck source=../lib/installer.sh
    source "${FYS_ROOT}/lib/installer.sh"
}
