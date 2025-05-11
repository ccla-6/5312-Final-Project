#!/bin/bash 
#SBATCH --job-name=gatk_gvcf
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 7
#SBATCH --mem=20G
#SBATCH --qos=general
#SBATCH --partition=xeon
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%A_%a.out
#SBATCH -e %x_%A_%a.err
#SBATCH --array=[0-4]


hostname
date

# make sure partition is specified as `xeon` to prevent slowdowns on amd processors. 

# load required software

module load GATK/4.0

# input/output
INDIR=../../results/03_Alignment/bwa_align/

OUTDIR=../../results/05_variantCalling/gatk
mkdir -p $OUTDIR

# choose a sample for array task
SAMPLELIST=(SRR24300331 SRR24300332 SRR24300333 SRR24300335 SRR24300357)
SAMPLE=${SAMPLELIST[$SLURM_ARRAY_TASK_ID]}

# set a variable for the reference genome location
GEN=../../genome/canfam4.0.fna

# run haplotype caller on one sample
gatk HaplotypeCaller \
     -R ${GEN} \
     -I ${INDIR}/${SAMPLE}.bam \
     -ERC GVCF \
     --output ${OUTDIR}/${SAMPLE}.g.vcf


