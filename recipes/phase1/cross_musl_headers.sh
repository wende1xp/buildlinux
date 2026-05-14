cross_musl_headers() {
    msg_now_building "Cabeçalhos do Musl"

    fetch_pkg musl
    extract_pkg musl
    cd "$SOURCES/build/${PKGDIR[musl]}"

    _set_custom_configure

    make DESTDIR=$ROOTFS install-headers
    
    cleanup_build_dir musl
}
