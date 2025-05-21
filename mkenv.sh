#!/bin/bash

# Nombre del directorio
DIRECTORY_NAME="setr"

# URL del archivo tar.gz de Eclipse
ECLIPSE_URL="https://eclipse.c3sl.ufpr.br/technology/epp/downloads/release/2025-03/R/eclipse-embedcpp-2025-03-R-linux-gtk-x86_64.tar.gz"
ECLIPSE_TAR_GZ_FILE=$(basename "$ECLIPSE_URL" | sed 's/?.*//')

echo "Creando directorio $DIRECTORY_NAME ..."
mkdir -p "$DIRECTORY_NAME"
mkdir -p "$DIRECTORY_NAME/tmp"

if [ $? -ne 0 ]; then
    echo "Error: No se pudo crear el directorio $DIRECTORY_NAME. Verificar permisos."
    exit 1
fi

cd "$DIRECTORY_NAME" || { echo "Error: No se pudo acceder al directorio $DIRECTORY_NAME."; exit 1; }

echo "Descargando Eclipse" 
wget "$ECLIPSE_URL"

if [ $? -ne 0 ]; then
    echo "Error: No se pudo descargar el archivo. Verificar conexión a internet."
    exit 1
fi

echo "Descomprimiendo Eclipse..."
tar -xzf "$ECLIPSE_TAR_GZ_FILE"

if [ $? -ne 0 ]; then
    echo "Error: No se pudo descomprimir el archivo."
    exit 1
fi

#echo "Eliminando archivos descargados"
#rm "$TAR_GZ_FILE"

