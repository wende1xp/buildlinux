umask 022

unset CC CXX CPPFLAGS CFLAGS CXXFLAGS LDFLAGS
unset LD_LIBRARY_PATH PKG_CONFIG_PATH PKG_CONFIG_LIBDIR DESTDIR

WORKSPACE="$HOME/buildenv"
BACKUP_DIR="$WORKSPACE/backups"
LOGS_DIR="$WORKSPACE/logs"

SESSION_FILE="$WORKSPACE/.session"

IMGDIR="$WORKSPACE/images"
IMGNAME="system"
IMGSIZE="16G"
IMGFMT="qcow2"

ROOTFS="$ROOTFS"
ROOTLABEL="BuildLinux"

BOOTFS="$ROOTFS/boot/efi"
BOOTLABEL="boot"
BOOTSIZE="512M"

SOURCES="$ROOTFS/sources"
TOOLCHAIN="$ROOTFS/toolchain"

SYSTARGET="x86_64-pc-linux-musl"
TARGETARCH="${SYSTARGET%%-*}"

MAKE_JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null)"
HOSTARCH="$(clang -dumpmachine | cut -d- -f1)"

I_KNOW_WHAT_I_DOING=no ## Ignora verificação de processador e memória ram !!!1!!!1

PATH=/usr/bin
if [ ! -L /bin ]; then
	PATH=/bin:$PATH
fi

export WORKSPACE
export BACKUP_DIR
export LOGS_DIR
export IMGDIR
export IMGNAME
export SESSION_FILE
export ROOTFS
export BOOTFS
export SOURCES
export TOOLCHAIN
export SYSTARGET
export TARGETARCH
export MAKE_JOBS
export HOSTARCH
export I_KNOW_WHAT_I_DOING
export PATH=$TOOLCHAIN/bin:$PATH


