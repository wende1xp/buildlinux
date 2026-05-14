verify_deps() {
    local missing=()
    local dep

    for dep in \
        clang clang++ cmake ninja meson \
        wget tar patch make ccache
    do
        command -v "$dep" >/dev/null 2>&1 || \
            missing+=("$dep")
    done

    if [ "${#missing[@]}" -ne 0 ]; then
        printf 'Dependências ausentes: %s\n' "${missing[*]}"
        
        msg_error "Instale as dependências necessárias antes de continuar."
        
        exit 1
    fi
}

verify_deps
