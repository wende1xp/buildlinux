declare -A URL
declare -A TARBALL
declare -A PKGDIR

load_manifest() {

    while IFS='|' read -r name url tarball pkgdir
    do
        URL["$name"]="$url"
        TARBALL["$name"]="$tarball"
        PKGDIR["$name"]="$pkgdir"

    done < "$SCRIPT_DIR/sources.manifest"
}

fetch_pkg() {
    local pkg="$1"
    local destdir="$SOURCES/${TARBALL[$pkg]}"

    if [ -f "$destdir" ]; then
        msg "${TARBALL[$pkg]} já existe, pulando o download."
    else
        msg "Baixando ${TARBALL[$pkg]}..."
        wget --tries=5 --waitretry=3 --timeout=15 --retry-connrefused -q --show-progress -O "$destdir" "${URL[$pkg]}"
    	msg "Download Concluído."
    fi
}

extract_pkg() {
    local pkg="$1"
    local destdir="$SOURCES/build/${PKGDIR[$pkg]}"

    if [ -d "$destdir" ]; then
        warn "Diretório $destdir já existe. Removendo para extrair uma nova cópia limpa..."
        rm -rf "$destdir"
    fi

    msg "Extraindo ${TARBALL[$pkg]}..."
    tar -xf "$SOURCES/${TARBALL[$pkg]}" -C "$SOURCES/build"

    if [ ! -d "$destdir" ]; then
        local realname
        realname=$(tar -tf "$SOURCES/${TARBALL[$pkg]}" | head -1 | cut -d/ -f1)
        
        if [ -d "$SOURCES/build/$realname" ]; then
            mv "$SOURCES/build/$realname" "$destdir"
        else
            die "Não foi possível localizar o diretório extraído para '$pkg'"
        fi
    fi
}

cleanup_build_dir() {
    local pkg="$1"
    local destdir="$SOURCES/build/${PKGDIR[$pkg]}"
    
    warn "Removendo o diretório $destdir..."
    rm -rf "$destdir"
}

prepare_environment() {
    local imgctl="$SCRIPT_DIR/helpers/imgctl"

    if [ -f "$SESSION_FILE" ]; then
        msg "Continuação detectada"

        if sudo \
            IMGDIR="$IMGDIR" \
            IMGNAME="$IMGNAME" \
            IMGSIZE="$IMGSIZE" \
            IMGFMT="$IMGFMT" \
            ROOTFS="$ROOTFS" \
            ROOTLABEL="$ROOTLABEL" \
            BOOTLABEL="$BOOTLABEL" \
            BOOTSIZE="$BOOTSIZE" \
            "$imgctl" mount >/dev/null 2>&1
        then
            ok "Ambiente existente montado"
        else
            error "Falha ao montar ambiente existente"
            return 1
        fi

    else
        msg "Nova build detectada"

        if sudo \
            IMGDIR="$IMGDIR" \
            IMGNAME="$IMGNAME" \
            IMGSIZE="$IMGSIZE" \
            IMGFMT="$IMGFMT" \
            ROOTFS="$ROOTFS" \
            ROOTLABEL="$ROOTLABEL" \
            BOOTLABEL="$BOOTLABEL" \
            BOOTSIZE="$BOOTSIZE" \
            "$imgctl" build >/dev/null 2>&1
        then
            ok "Imagem criada e montada"
        else
            error "Falha ao criar ambiente"
            return 1
        fi

    fi
}

clear_image_state() {
    rm -f "$SESSION_FILE"
}

build_interloper() {
    local name="$1"
    local package="$2"
    local script="$3"

    local script_name
    script_name="$(basename "$script" .sh)"

    local logfile="$LOGDIR/$script_name.log"
    local state_file="$STATE_BUILD"

    local state_key
    state_key="$(
        printf '%s' "$script_name" |
        tr '[:lower:]' '[:upper:]' |
        sed 's/[^A-Z0-9]/_/g'
    )"

    local state="HAS_${state_key}"

    local lock="${state_file}.lock"

    if ! exec 9>"$lock"; then
        error "Não foi possível abrir lockfile"
        return 1
    fi

    if ! flock -n 9; then
        error "Estado em uso, aguarde e tente novamente"
        exec 9>&-
        return 2
    fi

    if grep -qE "^${state}=1(\r)?$" "$state_file" 2>/dev/null; then
        skip "$name já foi compilado"

        flock -u 9
        exec 9>&-

        return 0
    fi

    now_building "$name"

    if . "$script" >"$logfile" 2>&1; then
        ok "$name compilado com sucesso"

        local tmp
        tmp="$(mktemp "${state_file}.XXXX")"

        if grep -qE "^${state}=" "$state_file" 2>/dev/null; then
            sed "s/^${state}=.*/${state}=1/" \
                "$state_file" >"$tmp"
        else
            cp "$state_file" "$tmp" 2>/dev/null || true
            printf '%s=1\n' "$state" >>"$tmp"
        fi

        mv "$tmp" "$state_file"

        chmod 600 "$state_file"

        flock -u 9
        exec 9>&-

        return 0
    fi

    local build_dir=""

    if [[ -n "${PKGDIR[$package]:-}" ]]; then
        build_dir="$SOURCES/build/${PKGDIR[$package]}"

        if [[ -d "$build_dir" ]]; then
            warn "Removendo o diretório $build_dir..."
            rm -rf "$build_dir"
        fi
    fi

    error "Falha na compilação do $name"

    log "Últimas 20 linhas do log: "
    [ -f "$logfile" ] && tail -n 20 "$logfile"
    log "Fim do log: "

    flock -u 9
    exec 9>&-

    return 1
}

file_interloper() {
    local name="$1"
    local func="$2"

    local state_file="$STATE_FILE"

    local state_key
    state_key="$(
        printf '%s' "$func" |
        tr '[:lower:]' '[:upper:]' |
        sed 's/[^A-Z0-9]/_/g'
    )"

    local state="HAS_${state_key}"

    local lock="${state_file}.lock"

    if ! exec 8>"$lock"; then
        error "Não foi possível abrir lockfile"
        return 1
    fi

    if ! flock -n 8; then
        error "Estado de arquivos em uso"
        exec 8>&-
        return 1
    fi

    if grep -qE "^${state}=1(\r)?$" "$state_file" 2>/dev/null; then
        msg "$name já criado"

        flock -u 8
        exec 8>&-

        return 0
    fi

    now_building "$name"

    if "$func"; then
        ok "$name criado com sucesso"

        local tmp
        tmp="$(mktemp "${state_file}.XXXX")"

        grep -vE "^${state}=" \
            "$state_file" >"$tmp" 2>/dev/null || true

        printf '%s=1\n' "$state" >>"$tmp"

        mv "$tmp" "$state_file"

        chmod 600 "$state_file"

        flock -u 8
        exec 8>&-

        return 0
    fi

    error "Falha ao criar $name"

    flock -u 8
    exec 8>&-

    return 1
}

do_backup() {
    local name="$1"
    
    msg "Criando backup"
    tar -cvJpf "$BACKUP_DIR/$name.tar.xz" -C "$ROOTFS" .
}

enter_chroot(){
    :
}
