#!/bin/bash

#SBATCH --job-name=FastQC_SCR
#SBATCH -p short
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=4
#SBATCH --mem=12G
#SBATCH --time=03:00:00
#SBATCH --mail-user=ac.cabreraj@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH -o fastqc_SCR_%j.log

set -e
set -o pipefail

##############################
# CONFIG
##############################
BASE_DIR=/hpcfs/home/cursos/bcom4102/grupos/Grupo_03/Pyfinal
THREADS=$SLURM_CPUS_PER_TASK

cd "$BASE_DIR"

module load fastqc

##############################
# FUNCIÓN
##############################
procesar_clean() {
    GRUPO=$1

    CLEAN="$GRUPO/clean"
    REPORTS="$GRUPO/reports"

    mkdir -p "$REPORTS"

    echo "=================================="
    echo "Procesando: $GRUPO"
    echo "Inicio: $(date)"
    echo "=================================="

    shopt -s nullglob

    for R1 in "$CLEAN"/*_clean_R1.fastq.gz; do
        BASE=$(basename "$R1" _clean_R1.fastq.gz)
        R2="$CLEAN/${BASE}_clean_R2.fastq.gz"

        if [[ -f "$R2" ]]; then
            echo "FastQC para $BASE"

            fastqc \
                --threads "$THREADS" \
                "$R1" \
                "$R2" \
                -o "$REPORTS"
        else
            echo "WARNING: No se encontró pareja para $R1"
        fi
    done

    echo "Terminado: $GRUPO ($(date))"
}

##############################
# EJECUCIÓN SCR
##############################

procesar_clean "SCR/1"
procesar_clean "SCR/2"
procesar_clean "SCR/3"
procesar_clean "SCR/4"

echo "=================================="
echo "FastQC CLEAN SCR terminado ✔"
echo "=================================="
