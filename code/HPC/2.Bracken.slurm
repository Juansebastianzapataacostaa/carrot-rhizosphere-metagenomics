#!/bin/bash
#SBATCH -p short
#SBATCH --job-name=Bracken_G3
#SBATCH --cpus-per-task=8
#SBATCH --mem=100G
#SBATCH --time=04:00:00
#SBATCH --array=0-11%4
#SBATCH --output=logs_Bracken/Bracken_%A_%a.out
#SBATCH --error=logs_Bracken/Bracken_%A_%a.err
#SBATCH --mail-user=ac.cabreraj@uniandes.edu.co
#SBATCH --mail-type=BEGIN,END,FAIL

# ---------------------------------------------------------
# 1. Directorios y Rutas
# ---------------------------------------------------------
BASE="/hpcfs/home/cursos/bcom4102/grupos/Grupo_03/Pyfinal"
DB="/hpcfs/shared/bcem/databases/kraken2/Standard/20241228"

# Lista de muestras para procesar en paralelo
MUESTRAS=("SCR/1" "SCR/2" "SCR/3" "SCR/4" "MCR/1" "MCR/2" "MCR/3" "MCR/4" "BS/1" "BS/2" "BS/3" "BS/4")
MUESTRA_ACTUAL=${MUESTRAS[$SLURM_ARRAY_TASK_ID]}

# ---------------------------------------------------------
# 2. Configuración de Entorno
# ---------------------------------------------------------
source /hpcfs/apps/conda4.12.0/etc/profile.d/conda.sh
conda activate bracken_env

# ---------------------------------------------------------
# 3. Preparación de Carpetas
# ---------------------------------------------------------
KRAKEN_REPORT="$BASE/$MUESTRA_ACTUAL/taxonomy/kraken_report.txt"
OUT_DIR="$BASE/$MUESTRA_ACTUAL/taxonomy"

# Crear carpeta de logs si no existe
mkdir -p logs_Bracken

echo "---------------------------------------------------"
echo "Iniciando Bracken para: $MUESTRA_ACTUAL"
echo "Usando reporte: $KRAKEN_REPORT"
echo "---------------------------------------------------"

# ---------------------------------------------------------
# 4. Ejecución de Bracken
# ---------------------------------------------------------

# Nota: Usamos -r 150 porque confirmamos la existencia de 
# 'database150mers.kmer_distrib' en la base de datos.

# Estimación a nivel de ESPECIE (-l S)
bracken \
    -d "$DB" \
    -i "$KRAKEN_REPORT" \
    -o "$OUT_DIR/bracken_species.txt" \
    -w "$OUT_DIR/bracken_species_report.txt" \
    -r 150 \
    -l S \
    -t 8

# Estimación a nivel de FAMILIA (-l F)
bracken \
    -d "$DB" \
    -i "$KRAKEN_REPORT" \
    -o "$OUT_DIR/bracken_family.txt" \
    -w "$OUT_DIR/bracken_family_report.txt" \
    -r 150 \
    -l F \
    -t 8

echo "---------------------------------------------------"
echo "Finalizado con éxito para: $MUESTRA_ACTUAL"
echo "---------------------------------------------------"
