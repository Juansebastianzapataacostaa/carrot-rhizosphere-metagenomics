#!/bin/bash
#SBATCH --job-name=prodigal_G3
#SBATCH --partition=short
#SBATCH --cpus-per-task=4
#SBATCH --mem=10G
#SBATCH --mail-user=ac.cabreraj@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH --time=04:00:00
#SBATCH --array=0-11%4
#SBATCH --output=logs_prodigal/prod_%A_%a.out

BASE="/hpcfs/home/cursos/bcom4102/grupos/Grupo_03/Pyfinal"

MUESTRAS=("SCR/1" "SCR/2" "SCR/3" "SCR/4" "MCR/1" "MCR/2" "MCR/3" "MCR/4" "BS/1" "BS/2" "BS/3" "BS/4")

MUESTRA_ACTUAL=${MUESTRAS[$SLURM_ARRAY_TASK_ID]}

echo "Procesando: $MUESTRA_ACTUAL"

module load prodigal

INPUT_DIR="$BASE/$MUESTRA_ACTUAL/assembly_15M"
OUT_DIR="$BASE/$MUESTRA_ACTUAL/annotation"

mkdir -p $OUT_DIR
mkdir -p logs_prodigal

if [ ! -f "$INPUT_DIR/asm.contigs.fa" ]; then
    echo "ERROR: no existe $INPUT_DIR/asm.contigs.fa"
    exit 1
fi

prodigal \
  -i $INPUT_DIR/asm.contigs.fa \
  -a $OUT_DIR/proteins.faa \
  -d $OUT_DIR/genes.fna \
  -o $OUT_DIR/prodigal_output.txt \
  -p meta

echo "Prodigal completado para: $MUESTRA_ACTUAL"
