#!/bin/bash
#SBATCH -p short
#SBATCH --mem=120G
#SBATCH -c 8
#SBATCH --time=08:00:00
#SBATCH --job-name=Kraken2_Final
#SBATCH --array=0-11%1
#SBATCH --mail-user=ac.cabreraj@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH --output=logs_kraken/Kraken2_%A_%a.out
#SBATCH --error=logs_kraken/Kraken2_%A_%a.err

# 1. Rutas (Basadas en tu imagen y tu estructura actual)
BASE="/hpcfs/home/cursos/bcom4102/grupos/Grupo_03/Pyfinal"
DB="/hpcfs/shared/bcem/databases/kraken2/Standard/20241228"

MUESTRAS=("SCR/1" "SCR/2" "SCR/3" "SCR/4" "MCR/1" "MCR/2" "MCR/3" "MCR/4" "BS/1" "BS/2" "BS/3" "BS/4")
MUESTRA_ACTUAL=${MUESTRAS[$SLURM_ARRAY_TASK_ID]}

# 2. Activar Conda (Tal cual estaba en tu imagen exitosa)
source /hpcfs/apps/conda4.12.0/etc/profile.d/conda.sh
conda activate kraken2

# 3. Directorios de trabajo
INPUT_DIR="$BASE/$MUESTRA_ACTUAL/subsample"
OUT_DIR="$BASE/$MUESTRA_ACTUAL/taxonomy"
mkdir -p $OUT_DIR logs_kraken

echo "Iniciando clasificación con Kraken2 para: $MUESTRA_ACTUAL"

# 4. Ejecución (Asegúrate que los nombres de archivo coincidan con subsample15M)
kraken2 \
  --db $DB \
  --threads 8 \
  --paired \
  --gzip-compressed \
  $INPUT_DIR/*_subsample15M_R1.fastq.gz $INPUT_DIR/*_subsample15M_R2.fastq.gz \
  --report $OUT_DIR/kraken_report.txt \
  --output $OUT_DIR/kraken_output.txt

echo "Clasificación terminada para: $MUESTRA_ACTUAL"
