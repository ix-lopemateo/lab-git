#!/bin/bash
#SBATCH -p hpc-bio-mendel
#SBATCH --chdir=/home/alumno11/LAB_3/lab-git
#SBATCH -J CutFiles-Lab3
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1

# Mostrar información del trabajo
echo "=========================================="
echo "Trabajo: Cortar ficheros FASTQ"
echo "Usuario: $(whoami)"
echo "Nodo: $(hostname)"
echo "Fecha inicio: $(date)"
echo "=========================================="
echo ""

# Listar ficheros antes del corte
echo "Ficheros FASTQ originales:"
ls -lh *.fastq
echo ""

# Ejecutar el script de corte en paralelo para cada fichero
# Usando srun para paralelizar

FILES=(*.fastq)
NUM_FILES=${#FILES[@]}

echo "Procesando $NUM_FILES ficheros en paralelo..."
echo ""

# Función para procesar un fichero
process_file() {
    file=$1
    divisor=$2
    
    echo "[Proceso $$] Procesando $file..."
    
    # Contar líneas
    TOTAL_LINES=$(wc -l < "$file")
    LINES_TO_KEEP=$((TOTAL_LINES / divisor))
    LINES_TO_KEEP=$((LINES_TO_KEEP / 4 * 4))
    
    # Cortar fichero
    head -n $LINES_TO_KEEP "$file" > "${file}.tmp"
    
    echo "[Proceso $$] $file completado: $TOTAL_LINES -> $LINES_TO_KEEP líneas"
}

export -f process_file

# Obtener el divisor según el usuario
USER=$(whoami)
NUM=$(echo $USER | grep -o '[0-9]*$')
if [ "$NUM" = "01" ]; then
    DIVISOR=10
else
    DIVISOR=$((10#$NUM))
fi

echo "Divisor calculado: $DIVISOR"
echo ""

# Ejecutar en paralelo usando srun
for file in "${FILES[@]}"; do
    srun -n 1 --exclusive bash -c "process_file $file $DIVISOR" &
done

# Esperar a que todos los procesos terminen
wait

echo ""
echo "Todos los ficheros procesados. Renombrando..."
echo ""

# Renombrar ficheros temporales
for file in *.fastq; do
    if [ -f "${file}.tmp" ]; then
        mv "${file}.tmp" "$file"
        echo "Renombrado: ${file}.tmp -> $file"
    fi
done

echo ""
echo "Ficheros FASTQ después del corte:"
ls -lh *.fastq
echo ""

echo "=========================================="
echo "Fecha fin: $(date)"
echo "Trabajo completado"
echo "=========================================="

