#!/bin/bash

#SBATCH --ntasks=15
#SBATCH --time=24:00:00
#SBATCH --mem=250G
#SBATCH --partition=bigmem_access  # Replace with your partition name

#Load necessary modules

module load python/2.7.13
module load r/3.2.3

echo "started"
date
python ./TRAPD-master/code/make_snp_file.py -v ./Burden/20_cev_priorit_burden_tranf.vcf.gz -o ./Burden/priorite_snp.txt --genecolname SYMBOL --vep
date
echo "done"
python ./TRAPD-master/code/count_cases.py -v main_gvc_tran_chr_trans.vcf.gz -s ./Burden/priorite_snp.txt -o ./Burden/cases_counts.txt []
echo "done"
python ./TRAPD-master/code/count_controls.py -v ../../../../../reference/gnomad.genomes.r3.0.sites.vcf.bgz -s ./Burden/priorite_snp.txt -o ./Burden/controlcounts.txt [ ]

Rscript  ./TRAPD-master/code/burden.R --casefile ./Burden/cases_counts.txt --casesize 20 --controlfile ./Burden/controlcounts.txt --controlsize 76156 --out ./Burden/CEV_trapd-rdf_2024_08_10

echo "done"
date

