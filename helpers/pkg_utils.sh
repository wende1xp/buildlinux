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
        echo "${TARBALL[$pkg]} já existe, pulando o download."
    else
        echo "Baixando ${TARBALL[$pkg]}..."
        wget --tries=5 --waitretry=3 --timeout=15 --retry-connrefused -q --show-progress -O "$destdir" "${URL[$pkg]}"
    	echo "Download Concluído."
    fi
}

extract_pkg() {
    local pkg="$1"
    local destdir="$SOURCES/build/${PKGDIR[$pkg]}"

    mkdir -p "$SOURCES/build"

    if [ -d "$destdir" ]; then
        echo "Diretório $destdir já existe. Removendo para extrair uma nova cópia limpa..."
        rm -rf "$destdir"
    fi

    echo "Extraindo ${TARBALL[$pkg]}..."
    tar -xf "$SOURCES/${TARBALL[$pkg]}" -C "$SOURCES/build"

    if [ ! -d "$destdir" ]; then
        local realname
        realname=$(tar -tf "$SOURCES/${TARBALL[$pkg]}" | head -1 | cut -d/ -f1)
        
        if [ -d "$SOURCES/build/$realname" ]; then
            mv "$SOURCES/build/$realname" "$destdir"
        else
            echo "Não foi possível localizar o diretório extraído para '$pkg'"
            exit 1
        fi
    fi
}

cleanup_build_dir() {
    local pkg="$1"
    local destdir="$SOURCES/build/${PKGDIR[$pkg]}"
    
    echo "Removendo o diretório $destdir..."
    rm -rf "$destdir"
}

interloper() {
    local name="$1"
    local func="$2"

    local logfile="$LOGDIR/$func.log"

    local state_file="$ROOTFS/tmp/.buildstate"
    local state="HAS_${func^^}"

    touch "$state_file"

    if grep -q "^${state}=1$" "$state_file"; then
        echo "==> $name já compilado"
        return 0
    fi

    echo "==> Compilando $name..."

    if "$func" >"$logfile" 2>&1; then
        echo "==> $name compilado com sucesso"

        if grep -q "^${state}=" "$state_file"; then
            sed -i "s/^${state}=.*/${state}=1/" "$state_file"
        else
            echo "${state}=1" >> "$state_file"
        fi

    else
        tail -n 20 "$logfile"
        echo "==> Falha na compilação do $name"
        exit 1
    fi
}

backup_sys() {
    local name="$1"
    
    echo "==> Criando backup"
    tar -cvJpf "$BACKUP_DIR/$name.tar.xz" -C "$ROOTFS" .
}