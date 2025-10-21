#!/bin/bash
#
# Script para configurar el entorno de desarrollo SETR (IF-025 PM UNPSJB)
# Versión con salida concisa.
#
# Este script crea la estructura de directorios y descarga/descomprime
# automáticamente el software requerido para Linux x64, según la guía.
#
# Se asume que los comandos 'curl' o 'wget' y 'tar' están instalados.
# ---

# Salir inmediatamente si un comando falla
set -e

# --- 1. Definición de Directorios y URLs ---

# Directorios base
SETR_DIR="$HOME/setr"
TOOLS_DIR="$SETR_DIR/tools"
ECLIPSE_DIR="$SETR_DIR/eclipse"

# Directorios de destino finales
GCC_DEST_DIR="$TOOLS_DIR/arm-none-eabi-gcc"
QEMU_DEST_DIR="$TOOLS_DIR/qemu"
OPENOCD_DEST_DIR="$TOOLS_DIR/openocd"

# URLs de descarga (Linux x64)
ECLIPSE_URL="https://eclipse.c3sl.ufpr.br/technology/epp/downloads/release/2025-09/R/eclipse-embedcpp-2025-09-R-linux-gtk-x86_64.tar.gz"
GCC_URL="https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v14.2.1-1.1/xpack-arm-none-eabi-gcc-14.2.1-1.1-linux-x64.tar.gz"
QEMU_URL="https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/download/v9.2.4-1/xpack-qemu-arm-9.2.4-1-linux-x64.tar.gz"
OPENOCD_URL="https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.12.0-7/xpack-openocd-0.12.0-7-linux-x64.tar.gz"

# Nombres de las carpetas que se crearán al descomprimir
GCC_EXTRACTED_NAME="xpack-arm-none-eabi-gcc-14.2.1-1.1"
QEMU_EXTRACTED_NAME="xpack-qemu-arm-9.2.4-1"
OPENOCD_EXTRACTED_NAME="xpack-openocd-0.12.0-7"

# --- 2. Función de Descarga ---

# Función helper para descargar archivos
# Uso: downloader "URL" "ARCHIVO_SALIDA" "NOMBRE_HERRAMIENTA"
downloader() {
  local url="$1"
  local output="$2"
  local name="$3"
  
  echo "📦 Descargando $name..."
  if command -v curl &> /dev/null; then
    # -L (seguir redirecciones), -s (silencioso), -o (archivo salida)
    curl -L -s -o "$output" "$url"
  elif command -v wget &> /dev/null; then
    # -q (quiet/silencioso), -O (archivo salida)
    wget -q -O "$output" "$url"
  else
    echo "Error: Se necesita 'curl' o 'wget' para descargar los archivos." >&2
    exit 1
  fi
}

# --- 3. Creación de Estructura de Directorios ---

echo "📂 Creando estructura de directorios en $SETR_DIR..."
mkdir -p "$SETR_DIR/workspace"
echo "   ... $SETR_DIR/workspace"
mkdir -p "$SETR_DIR/src"
echo "   ... $SETR_DIR/src"
mkdir -p "$TOOLS_DIR"
echo "   ... $SETR_DIR/tools"
mkdir -p "$ECLIPSE_DIR"
echo "   ... $SETR_DIR/eclipse"
echo "---"

# Crear un directorio temporal para las descargas
DOWNLOAD_DIR=$(mktemp -d)
# Asegurar que el directorio temporal se borre al salir
trap 'rm -rf "$DOWNLOAD_DIR"' EXIT
cd "$DOWNLOAD_DIR"

# --- 4. Descarga e Instalación de Software ---

# Eclipse
downloader "$ECLIPSE_URL" "eclipse.tar.gz" "Eclipse"
echo "   ... Instalando en $ECLIPSE_DIR"
tar -xzf "eclipse.tar.gz" -C "$ECLIPSE_DIR" --strip-components=1
rm "eclipse.tar.gz"
echo "---"

# Embedded Toolchain (GCC)
downloader "$GCC_URL" "gcc.tar.gz" "arm-none-eabi-gcc"
echo "   ... Instalando en $GCC_DEST_DIR"
tar -xzf "gcc.tar.gz" -C "$TOOLS_DIR"
mv "$TOOLS_DIR/$GCC_EXTRACTED_NAME" "$GCC_DEST_DIR"
rm "gcc.tar.gz"
echo "---"

# QEMU
downloader "$QEMU_URL" "qemu.tar.gz" "QEMU"
echo "   ... Instalando en $QEMU_DEST_DIR"
tar -xzf "qemu.tar.gz" -C "$TOOLS_DIR"
mv "$TOOLS_DIR/$QEMU_EXTRACTED_NAME" "$QEMU_DEST_DIR"
rm "qemu.tar.gz"
echo "---"

# OpenOCD
downloader "$OPENOCD_URL" "openocd.tar.gz" "OpenOCD"
echo "   ... Instalando en $OPENOCD_DEST_DIR"
tar -xzf "openocd.tar.gz" -C "$TOOLS_DIR"
mv "$TOOLS_DIR/$OPENOCD_EXTRACTED_NAME" "$OPENOCD_DEST_DIR"
rm "openocd.tar.gz"
echo "---"

# --- 5. Finalización ---

cd "$HOME"
echo "✅ ¡Proceso completado!"
echo "El entorno SETR está listo en $SETR_DIR"
