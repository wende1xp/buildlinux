
fetch_pkg musl
extract_pkg musl
cd "$SOURCES/build/${PKGDIR[musl]}"

custom_configure

make DESTDIR=$ROOTFS install-headers