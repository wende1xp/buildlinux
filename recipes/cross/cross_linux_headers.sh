
fetch_pkg linux
extract_pkg linux
cd "$SOURCES/build/${PKGDIR[linux]}"

make mrproper
make INSTALL_HDR_PATH=$ROOTFS/usr headers_install

