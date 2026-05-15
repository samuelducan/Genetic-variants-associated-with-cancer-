#!bin/bash
echo "Remember to havae indexed the genomes and to activate gakt before running this script"
set -e
echo "Hello and welcome to this main analysis"
echo "This script is for IGVAC study sample analysis"
mkdir -p /home/sgwayi/sam_phd_data/analysis/output_final
reference="/home/sgwayi/sam_phd_data/analysis/reference_genomes/GCF_000001405.40_GRCh38.p14_genomic.fasta"
dbsnp ="/home/sgwayi/sam_phd_data/analysis/reference_genomes/GCF_000001405.40.gz"
input_folder="/home/sgwayi/sam_phd_data/raw_data/Trimmed"

for folder in "$input_folder"/*/; do
    echo "working in folder named: $folder"
    cd "$folder" 
    echo "OBS: >>>succesfully launched analysis <<<" > "$output_final"main_analysis_log.txt
    date >> "$output_final"main_analysis_log.txt    
    b=$(basename "$(pwd)"
    #combing files
    echo "started combining reads for sample named: $b">> "$output_final"main_analysis_log.txt
    cat *R1.fastq.gz > "$b"_combined_R1.fastq.gz && cat *R2.fastq.gz > "$b"_combined_R2.fastq.gz
    echo "finished combining reads for sample named: $b">> "$output_final"main_analysis_log.txt
    date >> "$output_final"main_analysis_log.txt
    # now assembly
    echo "now assembling combined reads using reference based assembly... for sample: $b" >> "$output_final"main_analysis_log.txt
    date >> "$output_final"main_analysis_log.txt
    bwa mem -t 56 -R '@RG\tID:sample01\tSM:sample01\tPL:ILLUMINA' "$reference" "$b"_combined_R1.fastq.gz "$b"_combined_R2.fastq.gz > "$b".sam
    echo "assembl completed for sample: $b" >> "$output_final"main_analysis_log.txt
    date >> "$output_final"main_analysis_log.txt
    #now conversion and indexing
    echo "now converting to bam,sorting and indexing for sample: $b" >> "$output_final"main_analysis_log.txt
    samtools view -bS "$b".sam > "$b".bam
    samtools sort "$b".bam -o "$b"_sorted.bam
    samtools index "$b"_sorted.bam
    echo "GOOD Progress! finished assembling,sorting and indexing sample: $b" >> "$output_final"main_analysis_log.txt
    date >> "$output_final"main_analysis_log.txt
    #now starting varinat calling
    echo "GOOD Progress! finished assembling,sorting and indexing sample: $b" >> "$output_final"main_analysis_log.txt 
    echo "Now performing  variant calling for sample: $b" >> "$output_final"main_analysis_log.txt
    # marking duplicates
    gatk MarkDuplicates -I "$b"_sorted.bam -O "$b"_marked.bam -M "$b"_metrics.txt
    samtools index "$b"_marked.bam
    echo "marking duplicate and indexing completed for sample: $b" >> "$output_final"main_analysis_log.txt
    date >> "$output_final"main_analysis_log.txt
    echo "now performing recalibration for for sample: $b" >> "$output_final"main_analysis_log.txt
    #base recalibration
    gatk BaseRecalibrator -I "$b"_marked.bam -R "$reference" --known-sites "$dbsnp" -O "$b"_recal_data.table
    echo " completed recal for sample: $b" >> "$output_final"main_analysis_log.txt
    date >> "$output_final"main_analysis_log.txt
    echo "now applying bsqr for sample: $b" >> "$output_final"main_analysis_log.txt
    #applyiin bsqr to bam
    gatk ApplyBQSR -R "$reference" -I "$b"_marked.bam --bqsr-recal-file "$b"_recal_data.table -O "$b"_recal.bam
    date >> "$output_final"main_analysis_log.txt
    #variant calling on the sample
    echo "now creating vcf for sample: $b" >> "$output_final"main_analysis_log.txt
    gatk HaplotypeCaller -R "$reference" -I "$b"_recal.bam -O "$b".vcf
    date >> "$output_final"main_analysis_log.txt
    echo "now creating gvcf for sample: $b" >> "$output_final"main_analysis_log.txt
    #creating a gvcf for the sample
    gatk HaplotypeCaller -R "$reference" -I "$b"_recal.bam -O "$b".g.vcf.gz -ERC GVCF
    echo "Congratulation!!! workdone for sample: $b" >> "$output_final"main_analysis_log.txt
    date >> "$output_final"main_analysis_log.txt
    echo "Congratulation!!! workdone and files moving to output folder NB sample: $b" >> "$output_final"main_analysis_log.txt
    mv "$b".vcf /home/sgwayi/sam_phd_data/analysis/output_final/
    mv "$b".g.vcf.gz /home/sgwayi/sam_phd_data/analysis/output_final/
    echo "now removing intermediate files for sample: $b" >> "$output_final"main_analysis_log.txt
    df -h |head -n 4|tail -n 1 >> "$output_final"main_analysis_log.txt
    rm *.sam *.bam *.bai
    df -h |head -n 4|tail -n 1 >> "$output_final"main_analysis_log.txt
    echo "Succesfully Removed .sam .bam.bai for sample: $b" >> "$output_final"main_analysis_log.txt
done
echo "End.....analysis completed"
#Proceed to GVCF
