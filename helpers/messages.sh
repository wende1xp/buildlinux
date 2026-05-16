msg() {
    echo
    echo "[MSG]: $1"
}

error() {
    echo
    echo "[ERRO]: $1" >&2
}

warn() {
    echo
    echo "[AVISO]: $1" >&2
}

ok() {
    echo
    echo "[OK]: $1"
}

now_building() {
    echo
    echo "[BUILD]: $1"
}

die() {
    error "$1"
    exit 1
}

info() {
	echo "--------------------------------------------------------------------------------"
	echo "Informações:"
	echo ""
	echo "SYSROOT_DIR           : $ROOTFS"
	echo "TOOLCHAIN_DIR         : $TOOLCHAIN"
	echo "PATH                  : $PATH"
	echo "SYSTARGET             : $SYSTARGET"
	echo "HOST_ARCH             : $HOSTARCH"
	echo "TARGET_ARCH           : $TARGETARCH"
	echo "MAKE_JOBS             : -j$MAKE_JOBS"
	echo ""
	echo "--------------------------------------------------------------------------------"
}
