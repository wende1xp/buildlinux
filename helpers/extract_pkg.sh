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
