custom_cmake() {
  cmake_builddir=build

  case "${1-}" in
    '') ;;
    -*) ;;
    *)
      cmake_builddir=$1
      shift
      ;;
  esac

  cmake -S . -B "$cmake_builddir" \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_INSTALL_BINDIR=/usr/bin \
		-DCMAKE_INSTALL_SBINDIR=/usr/sbin \
		-DCMAKE_INSTALL_LIBDIR=/usr/lib \
		-DCMAKE_INSTALL_LIBEXECDIR=/usr/libexec \
		-DCMAKE_INSTALL_INCLUDEDIR=/usr/include \
		-DCMAKE_INSTALL_SYSCONFDIR=/etc \
		-DCMAKE_INSTALL_LOCALSTATEDIR=/var \
		-DCMAKE_INSTALL_MANDIR=/usr/share/man \
		-DCMAKE_INSTALL_INFODIR=/usr/share/info \
		"$@"
}
