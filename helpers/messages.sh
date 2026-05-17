if [[ -t 1 ]]; then
    CLR_RESET=$'\e[0m'

    CLR_RED=$'\e[1;31m'
    CLR_GREEN=$'\e[1;32m'
    CLR_YELLOW=$'\e[1;33m'
    CLR_BLUE=$'\e[1;34m'
    CLR_MAGENTA=$'\e[1;35m'
    CLR_CYAN=$'\e[1;36m'
    CLR_GRAY=$'\e[90m'

    CLR_BOLD=$'\e[1m'
else
    CLR_RESET=''

    CLR_RED=''
    CLR_GREEN=''
    CLR_YELLOW=''
    CLR_BLUE=''
    CLR_MAGENTA=''
    CLR_CYAN=''
    CLR_GRAY=''

    CLR_BOLD=''
fi

msg() {
    printf '%b\n' \
        "${CLR_CYAN}[MSG]${CLR_RESET} $1"
}

error() {
    printf '%b\n' \
        "${CLR_RED}[ERRO]${CLR_RESET} $1" >&2
}

warn() {
    printf '%b\n' \
        "${CLR_YELLOW}[AVISO]${CLR_RESET} $1" >&2
}

ok() {
    printf '%b\n' \
        "${CLR_GREEN}[OK]${CLR_RESET} $1"
}

now_building() {
    printf '\n%b\n' \
        "${CLR_BLUE}[BUILD]${CLR_RESET} ${CLR_BOLD}$1${CLR_RESET}"
}

skip() {
    printf '%b\n' \
        "${CLR_MAGENTA}[SKIP]${CLR_RESET} $1"
}

log() {
    printf '%b\n' \
        "${CLR_GRAY}[LOG]${CLR_RESET} $1"
}

die() {
    error "$1"
    exit 1
}

section() {
    printf '\n%b\n' \
        "${CLR_BOLD}==>${CLR_RESET} $1"
}

info() {
    printf '%b\n' \
"${CLR_GRAY}--------------------------------------------------------------------------------${CLR_RESET}"

    printf '%b\n' \
"${CLR_BOLD}Informações do Ambiente:${CLR_RESET}"

    echo

    printf '%-24s : %s\n' "WORKSPACE"      "$WORKSPACE"
    printf '%-24s : %s\n' "ROOTFS"         "$ROOTFS"
    printf '%-24s : %s\n' "BOOTFS"         "$BOOTFS"
    printf '%-24s : %s\n' "SOURCES"        "$SOURCES"
    printf '%-24s : %s\n' "TOOLCHAIN"      "$TOOLCHAIN"

    echo

    printf '%-24s : %s\n' "SYSTARGET"      "$SYSTARGET"
    printf '%-24s : %s\n' "HOSTARCH"       "$HOSTARCH"
    printf '%-24s : %s\n' "TARGETARCH"     "$TARGETARCH"
    printf '%-24s : -j%s\n' "MAKE_JOBS"    "$MAKE_JOBS"

    echo

    printf '%-24s : %s\n' "IMGNAME"        "$IMGNAME"
    printf '%-24s : %s\n' "IMGFMT"         "$IMGFMT"
    printf '%-24s : %s\n' "IMGSIZE"        "$IMGSIZE"
    printf '%-24s : %s\n' "IMGDIR"         "$IMGDIR"

    echo

    printf '%-24s : %s\n' "ROOTLABEL"      "$ROOTLABEL"
    printf '%-24s : %s\n' "BOOTLABEL"      "$BOOTLABEL"
    printf '%-24s : %s\n' "BOOTSIZE"       "$BOOTSIZE"

    echo

    printf '%-24s : %s\n' "LOGDIR"         "$LOGDIR"
    printf '%-24s : %s\n' "STATE_BUILD"    "$STATE_BUILD"

    printf '%b\n' \
"${CLR_GRAY}--------------------------------------------------------------------------------${CLR_RESET}"
}