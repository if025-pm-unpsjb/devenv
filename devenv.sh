#!/bin/bash
#
# Script para configurar el entorno de desarrollo SETR (IF-025 PM UNPSJB)
# Versión con chequeo de dependencias, salida concisa, plugins, PyOCD y Tracealyzer.
#
# Este script crea la estructura de directorios y descarga/descomprime
# automáticamente el software requerido para Linux x64, según la guía.
#
# Se asume que los comandos 'curl' o 'wget', 'tar' y 'unzip' están instalados.
# ---

# Salir inmediatamente si un comando falla
set -e

# --- 1. Comprobación de Dependencias ---
echo "🔎 Verificando dependencias..."
MISSING_TOOLS=""

# Comprobar 'tar'
if ! command -v tar &> /dev/null; then
  MISSING_TOOLS+=" tar"
fi

# Comprobar 'unzip'
if ! command -v unzip &> /dev/null; then
  MISSING_TOOLS+=" unzip"
fi

# Comprobar 'curl' o 'wget'
if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
  MISSING_TOOLS+=" 'curl' o 'wget'"
fi

if [ -n "$MISSING_TOOLS" ]; then
  echo "❌ Error: Faltan las siguientes utilidades requeridas:"
  echo "   ( $MISSING_TOOLS )"
  echo "Por favor, instálalas e intenta de nuevo."
  exit 1
fi
echo "   ... Dependencias encontradas."
echo "---"


# --- 2. Definición de Directorios y URLs ---

# Directorios base
SETR_DIR="$HOME/setr"
TOOLS_DIR="$SETR_DIR/tools"
ECLIPSE_DIR="$SETR_DIR/eclipse"

# Directorios de destino finales
GCC_DEST_DIR="$TOOLS_DIR/arm-none-eabi-gcc"
QEMU_DEST_DIR="$TOOLS_DIR/qemu"
OPENOCD_DEST_DIR="$TOOLS_DIR/openocd"
PYOCD_DEST_DIR="$TOOLS_DIR/pyocd"
TRACEALYZER_DEST_DIR="$TOOLS_DIR/Tracealyzer"

# URLs de descarga (Linux x64)
ECLIPSE_URL="https://eclipse.c3sl.ufpr.br/technology/epp/downloads/release/2025-09/R/eclipse-embedcpp-2025-09-R-linux-gtk-x86_64.tar.gz"
GCC_URL="https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v14.2.1-1.1/xpack-arm-none-eabi-gcc-14.2.1-1.1-linux-x64.tar.gz"
QEMU_URL="https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/download/v9.2.4-1/xpack-qemu-arm-9.2.4-1-linux-x64.tar.gz"
OPENOCD_URL="https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.12.0-7/xpack-openocd-0.12.0-7-linux-x64.tar.gz"
PYOCD_URL="https://github.com/pyocd/pyOCD/releases/download/v0.39.0/pyocd-linux-0.39.0.zip"
TRACEALYZER_URL="https://github.com/if025-pm-unpsjb/devenv/raw/master/assets/TzForFreeRTOS-3.1.2.zip"

# URLs y nombres de Plugins
TAD_URL="https://github.com/if025-pm-unpsjb/doc-repo/raw/master/resources/com.nxp.freertos.gdb.tad_1.0.2.201704260904.jar"
TAD_JAR="com.nxp.freertos.gdb.tad_1.0.2.201704260904.jar"
TRACE_CORE_URL="https://github.com/if025-pm-unpsjb/doc-repo/raw/master/resources/com.percepio.tracealyzer.core_1.0.6.v20180223734.jar"
TRACE_CORE_JAR="com.percepio.tracealyzer.core_1.0.6.v20180223734.jar"
TRACE_UI_URL="https://github.com/if025-pm-unpsjb/doc-repo/raw/master/resources/com.percepio.tracealyzer.ui_1.0.6.v20180223734.jar"
TRACE_UI_JAR="com.percepio.tracealyzer.ui_1.0.6.v20180223734.jar"

# Nombres de las carpetas que se crearán al descomprimir
GCC_EXTRACTED_NAME="xpack-arm-none-eabi-gcc-14.2.1-1.1"
QEMU_EXTRACTED_NAME="xpack-qemu-arm-9.2.4-1"
OPENOCD_EXTRACTED_NAME="xpack-openocd-0.12.0-7"
PYOCD_EXTRACTED_NAME="pyocd-linux-0.39.0"
TRACEALYZER_EXTRACTED_NAME="TzForFreeRTOS-3.1.2"

# --- 3. Función de Descarga ---

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
  fi
}

# --- 4. Creación de Estructura de Directorios ---

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

# --- 5. Descarga e Instalación de Software ---

# Eclipse
downloader "$ECLIPSE_URL" "eclipse.tar.gz" "Eclipse"
echo "   ... Instalando en $ECLIPSE_DIR"
tar -xzf "eclipse.tar.gz" -C "$ECLIPSE_DIR" --strip-components=1
rm "eclipse.tar.gz"

# Plugins de Eclipse
echo "   ... Instalando plugins"
PLUGINS_DEST_DIR="$ECLIPSE_DIR/plugins"

# Descargar plugins al directorio temporal
downloader "$TAD_URL" "$TAD_JAR" "Plugin FreeRTOS TAD"
downloader "$TRACE_CORE_URL" "$TRACE_CORE_JAR" "Plugin Tracealyzer (Core)"
downloader "$TRACE_UI_URL" "$TRACE_UI_JAR" "Plugin Tracealyzer (UI)"

# Moverlos a la carpeta de plugins de Eclipse
mv "$TAD_JAR" "$PLUGINS_DEST_DIR/"
mv "$TRACE_CORE_JAR" "$PLUGINS_DEST_DIR/"
mv "$TRACE_UI_JAR" "$PLUGINS_DEST_DIR/"
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

# PyOCD
downloader "$PYOCD_URL" "pyocd.zip" "PyOCD"
echo "   ... Instalando en $PYOCD_DEST_DIR"
unzip -q "pyocd.zip" -d "$TOOLS_DIR"
mv "$TOOLS_DIR/$PYOCD_EXTRACTED_NAME" "$PYOCD_DEST_DIR"
rm "pyocd.zip"
echo "---"

# Tracealyzer (TzForFreeRTOS)
downloader "$TRACEALYZER_URL" "tracealyzer.zip" "Tracealyzer (Tz)"
echo "   ... Instalando en $TRACEALYZER_DEST_DIR"
unzip -q "tracealyzer.zip" -d "$TOOLS_DIR"
mv "$TOOLS_DIR/$TRACEALYZER_EXTRACTED_NAME" "$TRACEALYZER_DEST_DIR"
rm "tracealyzer.zip"
echo "---"


# --- 6. Finalización ---

cd "$HOME"
echo "✅ ¡Proceso completado!"
echo "El entorno SETR está listo en $SETR_DIR"
