#!/bin/bash
#SBATCH --job-name=dbSNP
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
module load bcftools/1.6
module load GATK/4.1.3.0

### Annotating variants with dbSNP rsids. 

# make a directory if it doesn't exist
INDIR=../../results/05_variantCalling/freebayes/
OUTDIR=../../results/06_Annotate/dbSNP
mkdir -p ${OUTDIR}

# get the dbsnp set for chromosome 20
    # see here for details
	    # https://www.ncbi.nlm.nih.gov/variation/docs/human_variation_vcf/

	# download only a section of chr20 from dbsnp. change `20` to `chr20` in sequence ID column
	tabix -h https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/002/285/GCF_000002285.5_Dog10K_Boxer_Tasha/GCF_000002285.5_Dog10K_Boxer_Tasha_assembly_structure/Primary_Assembly/assembled_chromosomes/FASTA/chr37.fna.gz | \
	sed 's/^20/chr20/' | \
	bgzip -c >${OUTDIR}/chr37.dbsnp.vcf.gz
	tabix -p vcf -f ${OUTDIR}/chr37.dbsnp.vcf.gz
	# update the sequence dictionary
	gatk UpdateVCFSequenceDictionary -V ${OUTDIR}/chr37.dbsnp.vcf.gz --source-dictionary ${INDIR}/freebayes_normAP.vcf.gz --output ${OUTDIR}/chr37.dbsnp.contig.vcf.gz --replace=true
	tabix -p vcf -f ${OUTDIR}/chr37.dbsnp.contig.vcf.gz
	# remove intermediate files
	rm ${OUTDIR}/chr37.dbsnp.vcf.gz*

# annotate:
bcftools annotate -c ID \
--output-type z \
-a ${OUTDIR}/chr37.dbsnp.contig.vcf.gz \
${INDIR}/freebayes_normAP.vcf.gz >${OUTDIR}/freebayes_normAP.RSID.vcf.gz
