custom_configure() {
	./configure \
		--prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libdir=/usr/lib \
		--libexecdir=/usr/libexec \
		--includedir=/usr/include \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		"$@"
}

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

custom_meson() {
  meson_builddir=build

  case "${1-}" in
    '') ;;
    -*) ;;
    *)
      meson_builddir=$1
      shift
      ;;
  esac

  meson setup "$meson_builddir" \
		  --prefix=/usr \
		  --bindir=/usr/bin \
		  --sbindir=/usr/sbin \
		  --libdir=/usr/lib \
		  --libexecdir=/usr/libexec \
		  --includedir=/usr/include \
		  --sysconfdir=/etc \
		  --localstatedir=/var \
		  --mandir=/usr/share/man \
		  --infodir=/usr/share/info \
		  "$@"
}