cross_musl() {
    msg_now_building "Musl"

    fetch_pkg mimalloc
    fetch_pkg musl
    extract_pkg musl
    
    cd "$SOURCES/build/${PKGDIR[musl]}"

    [ -f src/string/x86_64/memcpy.s ]  && rm src/string/x86_64/memcpy.s
    [ -f src/string/x86_64/memmove.s ] && rm src/string/x86_64/memmove.s
    
    patch -Np1 -i ../musl-1.2.6-mimalloc.patch

    mkdir -p src/malloc/mimalloc/upstream
    tar -xf ../../mimalloc-3.3.0.tar.gz \
        --strip-components=1 \
        -C src/malloc/mimalloc/upstream \
        mimalloc-3.3.0/src mimalloc-3.3.0/include
        
    cp -v src/malloc/mimalloc/upstream/src/static.c src/malloc/mimalloc/static.c
    
    patch -Np1 -i ../mimalloc-3.3.0-for-musl.patch
    patch -Np1 -i ../musl-1.2.6-runtime-lib-from-compiler.patch
    
    _set_custom_configure --target="$SYSTARGET" --with-malloc=mimalloc
    make -j$MAKE_JOBS
    make install DESTDIR="$ROOTFS"
    
    cleanup_build_dir musl
}
