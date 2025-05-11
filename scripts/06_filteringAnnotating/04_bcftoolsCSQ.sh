#!/bin/bash
#SBATCH --job-name=bcftoolsCSQ
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=8G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

module load htslib/1.7
module load bcftools/1.20

# make a directory if it doesn't exist
INDIR=../../results/05_variantCalling/freebayes/
OUTDIR=../../results/06_Annotate/bcftoolsCSQ
mkdir -p ${OUTDIR}

GENOME=../../genome/canfam4.0.fna
VCFIN=../../results/05_variantCalling/freebayes/freebayes_filtered.vcf.gz
VCFOUT=${OUTDIR}/freebayes_annotated.vcf.gz

# first we need to download and fix up the GFF3 file. bcftools csq only works with ensembl GFF3 files (per the docs)
    # https://samtools.github.io/bcftools/howtos/csq-calling.html
# we'll grab it from here: https://useast.ensembl.org/Homo_sapiens/Info/Index
# and because it's an option, we'll only get chr20

wget -P ${OUTDIR} https://ftp.ensembl.org/pub/release-104/gff3/canis_lupus_familiaris/Canis_lupus_familiaris.CanFam3.1.104.chromosome.37.gff3.gz
gunzip ${OUTDIR}/Canis_lupus_familiaris.CanFam3.1.104.chromosome.37.gff3.gz
# fix up chromosome 20 names

GFF=${OUTDIR}//Canis_lupus_familiaris.CanFam3.1.104.chromosome.37.gff3.gz

# run bcftools csq
bcftools csq --phase a -f ${GENOME} -g ${GFF} ${VCFIN} -Oz -o ${VCFOUT}
