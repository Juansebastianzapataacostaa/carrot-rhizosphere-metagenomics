#!/bin/bash
#SBATCH --job-name=dbcan_full
#SBATCH --partition=medium
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=2-00:00:00
#SBATCH --mail-user=ac.cabreraj@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH --array=0-11%2
#SBATCH --output=logs_dbcan/dbcan_%A_%a.out
#SBATCH --error=logs_dbcan/dbcan_%A_%a.err

source ~/.bashrc

BASE="/hpcfs/home/cursos/bcom4102/grupos/Grupo_03/Pyfinal"

DB_DIR="/hpcfs/home/cursos/bcom4102/dbcan_local"

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

MUESTRA_ACTUAL=${MUESTRAS[$SLURM_ARRAY_TASK_ID]}

INPUT_PROT="$BASE/$MUESTRA_ACTUAL/annotation/proteins.faa"

OUT_DIR="$BASE/$MUESTRA_ACTUAL/annotation/dbcan"

mkdir -p "$OUT_DIR"
mkdir -p logs_dbcan

echo "======================================"
echo "Procesando: $MUESTRA_ACTUAL"
echo "Inicio: $(date)"
echo "======================================"

run_dbcan CAZyme_annotation \
--input_raw_data "$INPUT_PROT" \
--mode protein \
--output_dir "$OUT_DIR" \
--db_dir "$DB_DIR" \
--threads 16 \
--methods diamond,hmm,dbCANsub \
--no-run_signalp

echo "======================================"
echo "Finalizado: $(date)"
echo "======================================"
