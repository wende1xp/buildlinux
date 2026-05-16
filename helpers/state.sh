#!/usr/bin/env bash
set -euo pipefail

# Helper para marcar fases como concluídas e permitir retomar builds.
# Usa arquivos de stamp em $STATE_DIR (por padrão: $WORKSPACE/.build_state).

STATE_DIR="${WORKSPACE:-$HOME}/.build_state"
mkdir -p "$STATE_DIR"

state_mark_done() {
    local phase="$1"
    touch "$STATE_DIR/${phase}"
}

state_is_done() {
    local phase="$1"
    [[ -f "$STATE_DIR/${phase}" ]]
}

state_clear() {
    local phase="$1"
    rm -f "$STATE_DIR/${phase}"
}

state_list() {
    ls -1 "$STATE_DIR" 2>/dev/null || true
}
