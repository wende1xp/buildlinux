save_session() {
    cat > "$SESSION_FILE" << EOF
IMAGE_CREATED=${IMAGE_CREATED:-0}
IMAGE_FORMATTED=${IMAGE_FORMATTED:-0}
IMAGE_MOUNTED=${IMAGE_MOUNTED:-0}

NBD_DEVICE=${NBD_DEVICE:-}
EOF
}

load_session() {
    [ -f "$SESSION_FILE" ] || return 0
    source "$SESSION_FILE"
}

image_exists() {
    [ -f "$IMAGE_FILE" ]
}

image_is_mounted() {
    mountpoint -q "$ROOTFS"
}

nbd_is_connected() {
    local dev="$1"

    [ "$(blockdev --getsize64 "$dev" 2>/dev/null || echo 0)" -gt 0 ]
}

connect_image_nbd() {
    load_session

    if [ -n "${NBD_DEVICE:-}" ]; then
        if nbd_is_connected "$NBD_DEVICE"; then
            echo "==> Reutilizando $NBD_DEVICE"
            return 0
        fi
    fi

    NBD_DEVICE=$(find_free_nbd)

    echo "==> Conectando imagem em $NBD_DEVICE"

    qemu-nbd \
        --connect="$NBD_DEVICE" \
        "$IMAGE_FILE"

    sleep 1

    partprobe "$NBD_DEVICE"

    save_session
}

mount_image() {
    load_session

    image_is_mounted && return 0

    connect_image_nbd

    mkdir -p "$ROOTFS"
    mkdir -p "$BOOTFS"

    mount "${NBD_DEVICE}p2" "$ROOTFS"
    mount "${NBD_DEVICE}p1" "$BOOTFS"

    IMAGE_MOUNTED=1

    save_session
}

umount_image() {
    load_session

    sync

    umount "$BOOTFS" 2>/dev/null || true
    umount "$ROOTFS" 2>/dev/null || true

    if [ -n "${NBD_DEVICE:-}" ]; then
        qemu-nbd --disconnect "$NBD_DEVICE"
    fi

    IMAGE_MOUNTED=0
    NBD_DEVICE=""

    save_session
}

prepare_build_environment() {
    load_session

    mkdir -p \
        "$IMAGE_DIR" \
        "$LOGDIR" \
        "$BACKUP_DIR"

    if image_exists; then
        echo "==> Imagem existente detectada"

    else
        echo "==> Criando nova imagem"

        create_image
        partition_image
        format_image

        IMAGE_CREATED=1
        IMAGE_FORMATTED=1

        save_session
    fi

    mount_image
}
















image_exists() {
    [ -f "$IMG_DIR/$IMG_NAME.qcow2" ]
    return 0
}

image_is_mounted() {
    mountpoint -q "$ROOTFS"
}

nbd_is_connected() {
    local dev="$1"

    [ "$(blockdev --getsize64 "$dev" 2>/dev/null || echo 0)" -gt 0 ]
}

load_session() {
    [ -f "$SESSION_FILE" ] && source "$SESSION_FILE"
}

mount_existing_image() {
    load_session

    if [ -n "${NBD_DEVICE:-}" ]; then
        if ! nbd_is_connected "$NBD_DEVICE"; then
            qemu-nbd --connect="$NBD_DEVICE" "$IMAGE_FILE"
        fi
    else
        NBD_DEVICE=$(find_free_nbd)

        qemu-nbd \
            --connect="$NBD_DEVICE" \
            "$IMAGE_FILE"
    fi

    mount "${NBD_DEVICE}p2" "$ROOTFS"
}


# ------------------------------------------------------------------------------
# Funções que podem ser úteis
# ------------------------------------------------------------------------------

cleanup() {
    local exit_code=$?
    [[ $exit_code -eq 0 ]] && return

    warn "Erro detectado — executando limpeza..."

    for mnt in "${MOUNTS_DONE[@]:-}"; do
        umount "$mnt" 2>/dev/null && info "Desmontado: $mnt" || true
    done

    if [[ -n "$NBD_CONNECTED" ]]; then
        qemu-nbd --disconnect "$NBD_CONNECTED" 2>/dev/null && \
            info "NBD desconectado: $NBD_CONNECTED" || true
        sleep 1
        rmmod nbd 2>/dev/null || true
    fi
}

trap cleanup EXIT

find_free_nbd() {
    modprobe nbd max_part=8 2>/dev/null || true
    local dev
    for dev in /dev/nbd{0..15}; do
        [[ -b "$dev" ]] || continue
        # Dispositivo livre se size == 0
        if [[ "$(blockdev --getsize64 "$dev" 2>/dev/null || echo 1)" -eq 0 ]]; then
            echo "$dev"
            return 0
        fi
    done
    die "Nenhum dispositivo NBD livre encontrado (nbd0..nbd15)."
}

get_active_nbd() {
    local dev
    for dev in /dev/nbd{0..15}; do
        [[ -b "$dev" ]] || continue
        if [[ "$(blockdev --getsize64 "$dev" 2>/dev/null || echo 0)" -gt 0 ]]; then
            # Confirma que está conectado à nossa imagem
            if findmnt --source "${dev}p2" &>/dev/null || \
               findmnt --source "${dev}p1" &>/dev/null; then
                echo "$dev"
                return 0
            fi
            # Pode estar conectado mas não montado
            if [[ "$(blockdev --getsize64 "$dev")" -gt 0 ]]; then
                echo "$dev"
                return 0
            fi
        fi
    done
    return 1
}

cmd_build() {
    local imgname="$IMGNAME" imgsize="$IMGSIZE" imgdir="$IMGDIR"
    local bootsize="$BOOTSIZE"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--name)    imgname="$2";  shift 2 ;;
            -s|--size)    imgsize="$2";  shift 2 ;;
            -d|--dir)     imgdir="$2";   shift 2 ;;
            -b|--boot)    bootsize="$2"; shift 2 ;;
            -h|--help)    usage_build; return 0 ;;
            *) die "Opção desconhecida: $1" ;;
        esac
    done

    local imgfile="${imgdir}/${imgname}.${IMGFMT}"

    section "Verificações"
    check_root
    check_deps
    [[ -d "$imgdir" ]] || die "Diretório não encontrado: $imgdir"
    if [[ -f "$imgfile" ]]; then
        warn "Imagem já existe: $imgfile"
        read -rp "Sobrescrever? [s/N] " ans
        [[ "$ans" =~ ^[sS]$ ]] || die "Abortado."
        rm -f "$imgfile"
    fi
    ok "Ambiente pronto"

    section "Criando imagem"
    info "Arquivo : $imgfile"
    info "Formato : $IMGFMT"
    info "Tamanho : $imgsize  (boot: $bootsize)"
    qemu-img create -f "$IMGFMT" "$imgfile" "$imgsize"
    ok "Imagem criada"

    section "Conectando via NBD"
    local nbd
    nbd=$(find_free_nbd)
    NBD_CONNECTED="$nbd"
    info "Usando $nbd"
    qemu-nbd --connect="$nbd" "$imgfile"
    sleep 2
    ok "Conectado"

    section "Particionando"
    # GPT: p1 = EFI System (tipo 1), p2 = Linux filesystem
    fdisk "$nbd" <<EOF
g
n
1

+${bootsize}
t
1
n
2


w
EOF
    partprobe "$nbd"
    sleep 1
    ok "Tabela de partições gravada"

    section "Formatando"
    info "p1 → vfat (EFI)"
    mkfs.vfat -F 32 "${nbd}p1"
    info "p2 → ext4 (root)"
    mkfs.ext4 -F "${nbd}p2"
    sync
    ok "Formatação concluída"

    section "Aplicando labels"
    e2label  "${nbd}p2" "$ROOTLABEL"
    fatlabel "${nbd}p1" "$BOOTLABEL"
    ok "Labels definidas"

    section "Montando"
    umask 022
    mkdir -p "$P2MOUNT"
    mount -t ext4 "${nbd}p2" "$P2MOUNT"
    MOUNTS_DONE+=("$P2MOUNT")
    chown root:root "$P2MOUNT"
    chmod 755 "$P2MOUNT"

    mkdir -p "$P1MOUNT"
    mount -t vfat "${nbd}p1" "$P1MOUNT"
    MOUNTS_DONE+=("$P1MOUNT")
    ok "Imagem montada"

    # Tudo ok — limpa o trap
    NBD_CONNECTED=""
    MOUNTS_DONE=()

    section "Concluído"
    echo -e "${GREEN}Imagem pronta e montada:${RESET}"
    echo -e "  root → ${BOLD}$P2MOUNT${RESET}  (${nbd}p2)"
    echo -e "  efi  → ${BOLD}$P1MOUNT${RESET}  (${nbd}p1)"
}

cmd_mount() {
    local imgname="$IMGNAME" imgdir="$IMGDIR"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--name) imgname="$2"; shift 2 ;;
            -d|--dir)  imgdir="$2";  shift 2 ;;
            -h|--help) usage_mount; return 0 ;;
            *) die "Opção desconhecida: $1" ;;
        esac
    done

    local imgfile="${imgdir}/${imgname}.${IMGFMT}"

    section "Verificações"
    check_root
    check_deps
    [[ -f "$imgfile" ]] || die "Imagem não encontrada: $imgfile"

    if findmnt "$P2MOUNT" &>/dev/null; then
        warn "Imagem já está montada em $P2MOUNT"
        return 0
    fi
    ok "Ambiente pronto"

    section "Conectando via NBD"
    local nbd
    nbd=$(find_free_nbd)
    NBD_CONNECTED="$nbd"
    info "Usando $nbd"
    qemu-nbd --connect="$nbd" "$imgfile"
    partprobe "$nbd"
    sleep 1
    ok "Conectado"

    section "Montando"
    mkdir -p "$P2MOUNT"
    mount -t ext4 "${nbd}p2" "$P2MOUNT"
    MOUNTS_DONE+=("$P2MOUNT")

    mkdir -p "$P1MOUNT"
    mount -t vfat "${nbd}p1" "$P1MOUNT"
    MOUNTS_DONE+=("$P1MOUNT")
    ok "Imagem montada"

    NBD_CONNECTED=""
    MOUNTS_DONE=()

    section "Concluído"
    echo -e "${GREEN}Montado:${RESET}"
    echo -e "  root → ${BOLD}$P2MOUNT${RESET}  (${nbd}p2)"
    echo -e "  efi  → ${BOLD}$P1MOUNT${RESET}  (${nbd}p1)"
}

cmd_umount() {
    section "Verificações"
    check_root

    local nbd=""
    if ! findmnt "$P2MOUNT" &>/dev/null; then
        warn "Nada montado em $P2MOUNT — nada a fazer."
        return 0
    fi

    # Descobre qual NBD está em uso
    local src
    src=$(findmnt -no SOURCE "$P2MOUNT" 2>/dev/null || true)
    if [[ -n "$src" ]]; then
        nbd="${src%p*}"  # /dev/nbd0p2 → /dev/nbd0
    fi
    ok "NBD identificado: ${nbd:-desconhecido}"

    section "Desmontando"
    if findmnt "$P1MOUNT" &>/dev/null; then
        umount "$P1MOUNT"
        ok "Desmontado: $P1MOUNT"
    fi
    umount "$P2MOUNT"
    ok "Desmontado: $P2MOUNT"

    section "Desconectando NBD"
    if [[ -n "$nbd" ]]; then
        qemu-nbd --disconnect "$nbd"
        sleep 1
        ok "Desconectado: $nbd"
    fi

    rmmod nbd 2>/dev/null && ok "Módulo nbd removido" || \
        warn "Não foi possível remover módulo nbd (pode estar em uso por outro processo)"

    section "Concluído"
    ok "Imagem desmontada com sucesso"
}