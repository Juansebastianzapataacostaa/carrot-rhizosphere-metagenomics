#!/bin/bash

#SBATCH --job-name=Q_MCR
#SBATCH -p medium
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --mail-user=ac.cabreraj@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH -o soil_%j.log

set -e
set -o pipefail

##############################
# CONFIGURACIÓN GENERAL
##############################

BASE_DIR=/hpcfs/home/cursos/bcom4102/grupos/Grupo_03/Pyfinal
THREADS=$SLURM_CPUS_PER_TASK

mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

echo "======================================="
echo "Pipeline iniciado: $(date)"
echo "Directorio de trabajo: $(pwd)"
echo "CPUs asignadas: $THREADS"
echo "======================================="

##############################
# MÓDULOS / ENTORNO
##############################

module load sratoolkit
module load fastqc
module load seqtk

source ~/miniforge3/etc/profile.d/conda.sh
conda activate metagenomics

##############################
# MUESTRAS
##############################

MCR1=(SRR31030799)
MCR2=(SRR31030800)
MCR3=(SRR31030801)
MCR4=(SRR31030802)

##############################
# FUNCIÓN PRINCIPAL
##############################

procesar() {
    GRUPO=$1
    shift
    SAMPLES=("$@")

    mkdir -p "$GRUPO"/{raw,clean,subsample,reports,tmp}

    for SRR in "${SAMPLES[@]}"; do

        echo "---------------------------------------"
        echo "Procesando $SRR en $GRUPO"
        echo "Inicio: $(date)"
        echo "---------------------------------------"

        ##############################
        # 1. DESCARGA
        ##############################
        echo "[$(date)] Descargando $SRR..."

        fasterq-dump "$SRR" \
            --split-files \
            --split-3 \
            --threads "$THREADS" \
            --temp "$GRUPO/tmp" \
            -O "$GRUPO/tmp"

        ##############################
        # 2. COMPRESIÓN
        ##############################
        echo "[$(date)] Comprimiendo FASTQ..."

        pigz -p "$THREADS" "$GRUPO/tmp/${SRR}_1.fastq"
        pigz -p "$THREADS" "$GRUPO/tmp/${SRR}_2.fastq"

        mv "$GRUPO/tmp/${SRR}"*.gz "$GRUPO/raw/"

        ##############################
        # 3. FASTQC INICIAL
        ##############################
        echo "[$(date)] FastQC inicial..."

        fastqc \
            --threads "$THREADS" \
            "$GRUPO/raw/${SRR}_1.fastq.gz" \
            "$GRUPO/raw/${SRR}_2.fastq.gz" \
            -o "$GRUPO/reports"

        ##############################
        # 4. LIMPIEZA
        ##############################
        echo "[$(date)] Ejecutando fastp..."

        fastp \
            -i "$GRUPO/raw/${SRR}_1.fastq.gz" \
            -I "$GRUPO/raw/${SRR}_2.fastq.gz" \
            -o "$GRUPO/clean/${SRR}_clean_R1.fastq.gz" \
            -O "$GRUPO/clean/${SRR}_clean_R2.fastq.gz" \
            --detect_adapter_for_pe \
            --cut_front \
            --cut_tail \
            --cut_window_size 4 \
            --cut_mean_quality 20 \
            --qualified_quality_phred 30 \
            --length_required 50 \
            --thread "$THREADS" \
            --html "$GRUPO/reports/fastp_${SRR}.html" \
            --json "$GRUPO/reports/fastp_${SRR}.json"

        ##############################
        # 5. SUBMUESTREO
        ##############################
        echo "[$(date)] Submuestreando..."

        zcat "$GRUPO/clean/${SRR}_clean_R1.fastq.gz" | \
            seqtk sample -s100 - 0.3 | \
            gzip > "$GRUPO/subsample/${SRR}_sub_R1.fastq.gz"

        zcat "$GRUPO/clean/${SRR}_clean_R2.fastq.gz" | \
            seqtk sample -s100 - 0.3 | \
            gzip > "$GRUPO/subsample/${SRR}_sub_R2.fastq.gz"

        ##############################
        # 6. FASTQC FINAL
        ##############################
        echo "[$(date)] FastQC final..."

        fastqc \
            --threads "$THREADS" \
            "$GRUPO/subsample/${SRR}_sub_R1.fastq.gz" \
            "$GRUPO/subsample/${SRR}_sub_R2.fastq.gz" \
            -o "$GRUPO/reports"

        ##############################
        # 7. LIMPIEZA TEMPORALES
        ##############################
        echo "[$(date)] Limpiando temporales..."

        rm -rf "$GRUPO/tmp/${SRR}"*

        echo "[$(date)] $SRR terminado correctamente ✔"
        echo ""

    done
}

##############################
# EJECUCIÓN
##############################

procesar "MCR/1" "${MCR1[@]}"
procesar "MCR/2" "${MCR2[@]}"
procesar "MCR/3" "${MCR3[@]}"
procesar "MCR/4" "${MCR4[@]}"

echo "======================================="
echo "Pipeline terminado correctamente: $(date)"
echo "======================================="
