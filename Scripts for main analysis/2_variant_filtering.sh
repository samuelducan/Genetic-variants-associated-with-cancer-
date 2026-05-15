#!/bin/bash

#SBATCH --ntasks=15
#SBATCH --time=60:00:00
#SBATCH --mem=500G
#SBATCH --partition=bigmem_access  # Replace with your partition name

#Load necessary modules

#module load samtools/1.20
module load gatk/4.5.0.0              # Load GATK module (ensure this version is available on your cluster)
#module load bwa/0.7.15              # Load BWA module (if using BWA for alignment)

#setups

set -e
set -x
echo "This script is for IGVAC study sample analysis"

#Refernces
reference="/work/users/s/a/samgwayi/reference/GCF_000001405.40_GRCh38.p14_genomic.fasta"
dbsnp="/work/users/s/a/samgwayi/reference/GCF_000001405.40.gz"

#begin working on the data


gatk --java-options -Xmx250g SelectVariants -R "$reference" -V 21_control_jnt_gvc.vcf --select-type-to-include SNP -O 21_cont_sel.snvs.vcf

echo "done selecting snps"
sleep 10

gatk --java-options -Xmx250g SelectVariants -R "$reference" -V 21_control_jnt_gvc.vcf --select-type-to-include INDEL -O 21_cont_sel.indels.vcf

echo "done selecting INDEls"
sleep 5
date
echo "now filtering snps"

gatk --java-options -Xmx250g VariantFiltration \
  -V 21_cont_sel.snvs.vcf \
  -filter "QD < 2.0" --filter-name "QD2" \
  -filter "QUAL < 30.0" --filter-name "QUAL30" \
  -filter "SOR > 3.0" --filter-name "SOR3" \
  -filter "FS > 60.0" --filter-name "FS60" \
  -filter "MQ < 40.0" --filter-name "MQ40" \
  -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
  -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
  -O cont_snps_filt.vcf

echo "done with snps "
date
sleep 5

gatk --java-options -Xmx250g VariantFiltration -V 21_cont_sel.indels.vcf -filter "QD < 2.0" --filter-name "QD2" -filter "QUAL < 30.0" --filter-name "QUAL30" -filter "FS > 200.0" --filter-name "FS200" -filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" -O cont_indel_filtered.vcf

echo "done with filtering"
echo "now combining files"
gatk --java-options -Xmx250g MergeVcfs -I cont_snps_filt.vcf -I cont_indel_filtered.vcf -O 21_cont_SNPs_INDEL.filt.vcf

echo "Succesfuly done>>>><<<<< Good luck"
date
