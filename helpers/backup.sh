backup_sys() {
    local name="$1"
    
    echo "==> Criando backup
    tar -cvJpf "$BACKUP_DIR/$name.tar.xz" -C "$ROOTFS" .
}
