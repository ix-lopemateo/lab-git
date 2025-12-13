#!/bin/bash

# Script para cortar ficheros fastq según el número de usuario
# Uso: ./file-cut.sh

# Obtener el número de usuario (asumiendo formato alumnoXX)
USER=$(whoami)
# Extraer el número del usuario
NUM=$(echo $USER | grep -o '[0-9]*$')

# Si el número es 01, usar 10 en lugar de 1
if [ "$NUM" = "01" ]; then
    DIVISOR=10
else
    # Eliminar ceros a la izquierda
    DIVISOR=$((10#$NUM))
fi

echo "Usuario: $USER"
echo "Divisor: $DIVISOR"

# Procesar cada fichero .fastq
for file in *.fastq; do
    if [ -f "$file" ]; then
        echo "Procesando $file..."
        
        # Contar el número total de líneas
        TOTAL_LINES=$(wc -l < "$file")
        
        # Calcular cuántas líneas mantener (parte superior)
        LINES_TO_KEEP=$((TOTAL_LINES / DIVISOR))
        
        # Asegurar que sea múltiplo de 4 (formato FASTQ)
        LINES_TO_KEEP=$((LINES_TO_KEEP / 4 * 4))
        
        echo "  Total líneas: $TOTAL_LINES"
        echo "  Líneas a mantener: $LINES_TO_KEEP"
        
        # Cortar el fichero y guardar en temporal
        head -n $LINES_TO_KEEP "$file" > "${file}.tmp"
        
        echo "  Fichero cortado guardado temporalmente"
    fi
done

echo "Proceso completado"
