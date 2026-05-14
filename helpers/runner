runner() {
    local name="$1"
    local func="$2"
    local logfile="$LOGDIR/$name.log"

    echo "==> Compilando $name..."
    
    if "$func" > "$logfile" 2>&1; then
    	echo "==> $name compilado com sucesso"
    	
    else
    	tail -n 20 "$logfile"
    	echo "==> Falha na compilação do $name"
    	exit 1
    fi
}
