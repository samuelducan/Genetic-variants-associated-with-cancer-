#!/bin/bash
# Set input files
CASE_GENOTYPES="cases.geno.gvcf"
CONTROL_GENOTYPES="control.geno.gvcf"
PHENO_FILE="phenotype.txt"
OUTPUT_PREFIX="combined_data"

# Combine case and control genotype data using bcftools
bcftools merge -o ${OUTPUT_PREFIX}.vcf.gz -O z ${CASE_GENOTYPES} ${CONTROL_GENOTYPES}

# Convert vcf to plink format
plink --vcf ${OUTPUT_PREFIX}.vcf.gz --make-bed --out ${OUTPUT_PREFIX}

# Filter SNPs based on missing genotype rate, MAF, and HWE
plink --bfile ${OUTPUT_PREFIX} \
       --geno 0.05 \
       --maf 0.1 \
       --hwe 0.000001 \
       --make-bed --out ${OUTPUT_PREFIX}_filtered
# Run PCA
plink --bfile ${OUTPUT_PREFIX}_filtered --pca --out ${OUTPUT_PREFIX}_pca

# Run GWAS using PCA2 and PCA3 as covariates
plink --bfile ${OUTPUT_PREFIX}_filtered \
       --pheno ${PHENO_FILE} \
       --covar ${OUTPUT_PREFIX}_pca.eigenvec \
       --covar-number 2-3 \
       --logistic --out ${OUTPUT_PREFIX}_gwas
