#!/usr/bin/env bash

HOST_ARCH=$(uname -m)
HOST_THREADS=$(getconf _NPROCESSORS_ONLN 2>/dev/null)
HOST_RAM=$(awk '/MemTotal/ {print $2}' /proc/meminfo)

missing=()

if [ "${I_KNOW_WHAT_I_AM_DOING:-0}" != "1" ]; then

    if [ "$HOST_ARCH" != "x86_64" ]; then
        die "Arquitetura não suportada"
    fi

    if [ "$HOST_THREADS" -lt 4 ]; then
        warn "É desaconselhável executar esse programa em processadores com menos de 4 threads. Tempos maiores de compilação são esperados."
    fi

    if [ "$HOST_RAM" -lt $((4 * 1024 * 1024)) ]; then
        die "É recomendável no mínimo 4 GB de memória RAM para executar esse programa."
    fi

fi

for dep in \
    clang clang++ cmake ninja meson \
    wget tar patch make ccache
do
    command -v "$dep" >/dev/null 2>&1 || \
        missing+=("$dep")
done

if [ "${#missing[@]}" -ne 0 ]; then
    printf 'Dependências ausentes: %s\n' "${missing[*]}"

    die "Instale as dependências necessárias antes de continuar."
fi