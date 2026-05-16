cross_llvm_pass1() {
    # Carrega helper de estado para permitir retomar esta fase sem recompilar.
    REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")"/../.. && pwd)"
    # shellcheck disable=SC1090
    source "$REPO_ROOT/helpers/state.sh"
    if state_is_done "cross_llvm_pass1"; then
        msg_warn "Ignorando LLVM (Primeira Passagem): já concluído anteriormente."
        return 0
    fi
    msg_now_building "LLVM (Primeira Passagem)"
    
    fetch_pkg llvm
    extract_pkg llvm
    cd "$SOURCES/build/${PKGDIR[llvm]}"
    
    cmake -G Ninja -S llvm -B build \
    -DCMAKE_C_COMPILER=/usr/bin/clang \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_INSTALL_PREFIX=$TOOLCHAIN \
    -DLLVM_ENABLE_PROJECTS="lld;clang" \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
    -DCOMPILER_RT_BUILD_BUILTINS=ON \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_PROFILE=OFF \
    -DLLVM_DEFAULT_TARGET_TRIPLE="$SYSTARGET" \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DCLANG_DEFAULT_LINKER=lld \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DDEFAULT_SYSROOT="$ROOTFS"

    ninja -C build -j$MAKE_JOBS
    ninja -C build install/strip
    
    cleanup_build_dir llvm
    
    ln -sf clang        "$TOOLCHAIN/bin/$SYSTARGET-clang"
    ln -sf clang++      "$TOOLCHAIN/bin/$SYSTARGET-clang++"
    ln -sf clang        "$TOOLCHAIN/bin/$SYSTARGET-cc"
    ln -sf clang++      "$TOOLCHAIN/bin/$SYSTARGET-c++"

    ln -sf llvm-ar      "$TOOLCHAIN/bin/$SYSTARGET-ar"
    ln -sf llvm-ranlib  "$TOOLCHAIN/bin/$SYSTARGET-ranlib"
    ln -sf llvm-as      "$TOOLCHAIN/bin/$SYSTARGET-as"
    ln -sf llvm-nm      "$TOOLCHAIN/bin/$SYSTARGET-nm"
    ln -sf llvm-objcopy "$TOOLCHAIN/bin/$SYSTARGET-objcopy"
    ln -sf llvm-objdump "$TOOLCHAIN/bin/$SYSTARGET-objdump"
    ln -sf llvm-readelf "$TOOLCHAIN/bin/$SYSTARGET-readelf"
    ln -sf llvm-strip   "$TOOLCHAIN/bin/$SYSTARGET-strip"
    ln -sf ld.lld       "$TOOLCHAIN/bin/$SYSTARGET-ld"
    state_mark_done "cross_llvm_pass1"
}
