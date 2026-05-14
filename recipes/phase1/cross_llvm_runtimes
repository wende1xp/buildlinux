cross_llvm_runtimes() {
    msg_now_building "Runtimes do Clang"

    fetch_pkg llvm
    extract_pkg llvm
    
    cd "$SOURCES/build/${PKGDIR[llvm]}/runtimes"

    _set_custom_cmake build \
        -G Ninja \
        -DCMAKE_C_COMPILER="$TOOLCHAIN/bin/$SYSTARGET-clang" \
        -DCMAKE_CXX_COMPILER="$TOOLCHAIN/bin/$SYSTARGET-clang++" \
        -DCMAKE_SYSROOT="$ROOTFS" \
        -DCMAKE_FIND_ROOT_PATH="$ROOTFS;$ROOTFS/usr" \
        -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
        -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
        -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
        -DCMAKE_C_FLAGS="--target=$SYSTARGET" \
        -DCMAKE_CXX_FLAGS="--target=$SYSTARGET" \
        -DLLVM_ENABLE_RUNTIMES="libunwind;libcxxabi;libcxx" \
        -DLIBUNWIND_INSTALL_LIBRARY_DIR=/usr/lib \
        -DLIBCXXABI_INSTALL_LIBRARY_DIR=/usr/lib \
        -DLIBCXX_INSTALL_LIBRARY_DIR=/usr/lib \
        -DLLVM_ENABLE_ZLIB=OFF \
        -DLLVM_ENABLE_ZSTD=OFF \
        -DLLVM_ENABLE_LIBXML2=OFF \
        -DLIBCXX_HAS_MUSL_LIBC=ON \
        -DLIBCXX_HAS_ATOMIC_LIB=OFF \
        -DLIBCXXABI_HAS_CXA_THREAD_ATEXIT_IMPL=OFF \
        -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
        -DLIBCXX_USE_COMPILER_RT=ON \
        -DLIBCXXABI_USE_COMPILER_RT=ON \
        -DLIBUNWIND_USE_COMPILER_RT=ON \
        -DCMAKE_BUILD_TYPE=Release

    ninja -C build -j$MAKE_JOBS
    DESTDIR="$ROOTFS" ninja -C build install

    cleanup_build_dir llvm
}
