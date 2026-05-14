fetch_pkg() {
    local pkg="$1"
    local destdir="$SOURCES/${TARBALL[$pkg]}"

    mkdir -p "$SOURCES"

    if [ -f "$destdir" ]; then
        echo "${TARBALL[$pkg]} já existe, pulando o download."
    else
        echo "Baixando ${TARBALL[$pkg]}..."
        wget --tries=5 --waitretry=3 --timeout=15 --retry-connrefused -q --show-progress -O "$destdir" "${URL[$pkg]}"
    	echo "Download Concluído."
    fi
}
