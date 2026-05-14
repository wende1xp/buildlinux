umask 022

unset CC CXX CPPFLAGS CFLAGS CXXFLAGS LDFLAGS
unset LD_LIBRARY_PATH PKG_CONFIG_PATH PKG_CONFIG_LIBDIR DESTDIR

WORKSPACE="$HOME/buildenv"
BACKUP_DIR="$WORKSPACE/backups"
LOGS_DIR="$WORKSPACE/logs"
IMG_DIR="$WORKSPACE/images"

ROOTFS="$ROOTFS"

SOURCES="$ROOTFS/sources"
TOOLCHAIN="$ROOTFS/toolchain"

SYSTARGET="x86_64-pc-linux-musl"
TARGETARCH="${SYSTARGET%%-*}"

MAKE_JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
HOSTARCH="$(clang -dumpmachine | cut -d- -f1)"

PATH=/usr/bin
if [ ! -L /bin ]; then
	PATH=/bin:$PATH
fi

export WORKSPACE
export BACKUP_DIR
export LOGS_DIR
export IMG_DIR
export ROOTFS
export SOURCES
export TOOLCHAIN
export SYSTARGET
export TARGETARCH
export MAKE_JOBS
export HOSTARCH
export PATH=$TOOLCHAIN/bin:$PATH


