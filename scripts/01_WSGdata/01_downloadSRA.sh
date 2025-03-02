#!/bin/bash
#SBATCH --job-name=fasterq_dump_xanadu
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 12
#SBATCH --mem=15G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=first.last@uconn.edu
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

#################################################################
# Download fastq files from SRA 
#################################################################

# load software
module load parallel/20180122
module load sratoolkit/3.0.1

# The data are from this study:
    # https://www.ncbi.nlm.nih.gov/sra/?term=SRP107226


OUTDIR=../../data/WGS
    mkdir -p ${OUTDIR}
METADATA=../../metadata/SraRunTable.csv

# Get a list of SRA accession numbers to download, put them in a file

# there are 2 populations of foxes 6 tame and 6 agressive
    # the metadata table was downloaded from the SRA's "Run Selector" page.

# extract rows matching our population names, pull out the SRA accession number (the first column)
ACCLIST=../../metadata/SRR_Acc_List.txt
sed '1d' $METADATA | cut -f 1 -d "," >$ACCLIST

export TMPDIR=newtmpdir
mkdir $TMPDIR
# use parallel to download 2 accessions at a time. 
cat $ACCLIST | parallel -j 2 "fasterq-dump -O ${OUTDIR} {}"

# compress the files 
ls ${OUTDIR}/*fastq | parallel -j 10 gzip
