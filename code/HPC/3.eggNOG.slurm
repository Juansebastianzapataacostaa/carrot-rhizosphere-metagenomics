#!/bin/bash
#SBATCH -p short
#SBATCH --job-name=eggNOG_G3
#SBATCH --cpus-per-task=8
#SBATCH --mem=45G
#SBATCH --time=10:00:00
#SBATCH --mail-user=ac.cabreraj@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH --array=0-11
#SBATCH --output=logs_eggnog/egg_%A_%a.out
#SBATCH --error=logs_eggnog/egg_%A_%a.err

# Detener el script inmediatamente si ocurre un error
set -e

# =========================
# 1. Directorio base
# =========================
BASE="/hpcfs/home/cursos/bcom4102/grupos/Grupo_03/Pyfinal"

# =========================
# 2. Lista de muestras
# =========================
MUESTRAS=(
"SCR/1"
"SCR/2"
"SCR/3"
"SCR/4"
"MCR/1"
"MCR/2"
"MCR/3"
"MCR/4"
"BS/1"
"BS/2"
"BS/3"
"BS/4"
)

# =========================
# 3. Seleccionar muestra actual
# =========================
MUESTRA_ACTUAL=${MUESTRAS[$SLURM_ARRAY_TASK_ID]}

# Convertir SCR/1 -> SCR_1
NOMBRE_LIMPIO=$(echo "$MUESTRA_ACTUAL" | tr '/' '_')

# =========================
# 4. Rutas de entrada/salida
# =========================
INPUT_FAA="$BASE/$MUESTRA_ACTUAL/annotation/proteins.faa"
OUT_DIR="$BASE/$MUESTRA_ACTUAL/annotation"

# =========================
# 5. Verificación de archivo
# =========================
if [ ! -f "$INPUT_FAA" ]; then
    echo "ERROR: No existe $INPUT_FAA"
    exit 1
fi

# =========================
# 6. Crear carpeta de logs si no existe
# =========================
mkdir -p logs_eggnog

# =========================
# 7. Activar ambiente
# =========================
source /hpcfs/home/cursos/bcom4102/miniforge3/bin/activate \
/hpcfs/home/cursos/bcom4102/miniforge3/envs/eggnog_env

# =========================
# 8. Información de depuración
# =========================
echo "======================================="
echo "Muestra actual: $MUESTRA_ACTUAL"
echo "Nombre limpio: $NOMBRE_LIMPIO"
echo "Archivo entrada: $INPUT_FAA"
echo "Directorio salida: $OUT_DIR"
echo "======================================="

# =========================
# 9. Ejecutar eggNOG-mapper
# =========================
emapper.py \
    -i "$INPUT_FAA" \
    --output "$NOMBRE_LIMPIO" \
    --output_dir "$OUT_DIR" \
    --cpu 8 \
    -m diamond \
    --data_dir /hpcfs/shared/bcem/databases/eggnog/v5.0/eggnog-mapper \
    --override

# =========================
# 10. Mensaje final
# =========================
echo "Finalizado con éxito: $MUESTRA_ACTUAL"
echo "Resultados guardados en: $OUT_DIR"
