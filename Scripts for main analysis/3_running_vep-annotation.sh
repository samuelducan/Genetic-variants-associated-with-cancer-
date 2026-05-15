#!/bin/bash

#SBATCH --ntasks=15
#SBATCH --time=24:00:00
#SBATCH --mem=500G
#SBATCH --partition=bigmem_access  # Replace with your partition name

#Load necessary modules

#module load samtools/1.20
#module load gatk/4.5.0.0              # Load GATK module (ensure this version is available on your cluster)
#module load bwa/0.7.15              # Load BWA module (if using BWA for alignment)
module load vep/108                # Make sure this matches the module naming convention on your system
#setups

set -e
set -x
echo "This script is for IGVAC study VEP analysis"

mkdir -p vep_output

#Refernces
reference="/work/users/s/a/samgwayi/reference/GCF_000001405.40_GRCh38.p14_genomic.fasta"

date
# Run VEP
echo "started running"

vep -i 20_CEV_SNPs_INDEL.filtered.vcf \
  -o vep_output/20_Final_SNP_INDEL_vep_annotated.vcf \
  --vcf \
  --cache \
  --offline \
  --dir_cache /work/users/s/a/samgwayi/new_cache/ \
  --fasta "$reference"
echo "Succesfuly done>>>><<<<< Good luck"
date
