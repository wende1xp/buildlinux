cross_linux_headers() {
    msg_now_building "Cabeçalhos do Kernel Linux"

    fetch_pkg linux
    extract_pkg linux
    cd "$SOURCES/build/${PKGDIR[linux]}"

    make mrproper
    make INSTALL_HDR_PATH=$ROOTFS/usr headers_install

    cleanup_build_dir linux
}
