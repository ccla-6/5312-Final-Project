#!/bin/bash
#SBATCH --job-name=trimmomatic
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=15G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=first.last@uconn.edu
#SBATCH -o %x_%A_%a.out
#SBATCH -e %x_%A_%a.err
#SBATCH --array=[0-7]

hostname
date

#################################################################
# Trimmomatic
#################################################################

module load Trimmomatic/0.39

# set input/output directory variables
INDIR=../../data/WGS
TRIMDIR=../../results/02_qc/trimmed_fastq
mkdir -p $TRIMDIR

# adapters to trim out
ADAPTERS=/isg/shared/apps/Trimmomatic/0.39/adapters/TruSeq3-PE-2.fa

# sample bash array
SAMPLELIST=(SRR24300331 SRR24300332 SRR24300333 SRR24300335 SRR24300345 SRR24300349 SRR24300350 SRR24300357)

# run trimmomatic

SAMPLE=${SAMPLELIST[$SLURM_ARRAY_TASK_ID]}

java -jar $Trimmomatic PE -threads 4 \
        ${INDIR}/${SAMPLE}_1.fastq.gz \
        ${INDIR}/${SAMPLE}_2.fastq.gz \
        ${TRIMDIR}/${SAMPLE}_trim.1.fq.gz ${TRIMDIR}/${SAMPLE}_trim_orphans.1.fq.gz \
        ${TRIMDIR}/${SAMPLE}_trim.2.fq.gz ${TRIMDIR}/${SAMPLE}_trim_orphans.2.fq.gz \
        ILLUMINACLIP:"${ADAPTERS}":2:30:10 \
        SLIDINGWINDOW:4:15 MINLEN:45
