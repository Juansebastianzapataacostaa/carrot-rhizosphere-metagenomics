#!/bin/bash
#SBATCH --job-name=ncyc_G3
#SBATCH --partition=medium
#SBATCH --cpus-per-task=16
#SBATCH --mem=30G
#SBATCH --time=06:00:00
#SBATCH --mail-user=ac.cabreraj@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH --array=0-11%4
#SBATCH --output=logs_ncyc/ncyc_%A_%a.out
#SBATCH --error=logs_ncyc/ncyc_%A_%a.err

BASE="/hpcfs/home/cursos/bcom4102/grupos/Grupo_03/Pyfinal"
MUESTRAS=("SCR/1" "SCR/2" "SCR/3" "SCR/4" "MCR/1" "MCR/2" "MCR/3" "MCR/4" "BS/1" "BS/2" "BS/3" "BS/4")
MUESTRA_ACTUAL=${MUESTRAS[$SLURM_ARRAY_TASK_ID]}

NCYC_DB="/hpcfs/home/cursos/bcom4102/grupos/Grupo_03/dbs/NCyc_DB"
INPUT_PROT="$BASE/$MUESTRA_ACTUAL/annotation/proteins.faa"
OUT_DIR="$BASE/$MUESTRA_ACTUAL/annotation/ncyc"
mkdir -p $OUT_DIR logs_ncyc

module load diamond/2.0.15.153

diamond blastp \
  -d $NCYC_DB \
  -q $INPUT_PROT \
  -o $OUT_DIR/ncyc_hits.tsv \
  -e 1e-5 \
  --max-target-seqs 1 \
  --id 60 \
  --query-cover 70 \
  --outfmt 6 qseqid sseqid pident qcovhsp length evalue bitscore \
  --threads 16

echo "NCyc completado para: $MUESTRA_ACTUAL"
