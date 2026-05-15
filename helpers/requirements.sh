verify_dependencies() {
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

verify_hardware() {
    if [ "$(uname -m)" != "x86_64" ]; then
        msg_error "Arquitetura não suportada"
        
    elif [ "$(getconf _NPROCESSORS_ONLN 2>/dev/null)" -lt 4 ]; then
        msg_warn "É desaconselhável executar esse programa em processadores com menos de 4 threads. Tempos maiores de compilação são esperados."

    elif [ "$(awk '/MemTotal/ {print $2}' /proc/meminfo)" -lt $((4 * 1024 * 1024)) ]; then
        msg_error "É recomendável no mínimo 4 GB de memória RAM para executar esse programa."
    fi
}
