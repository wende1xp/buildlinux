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
