#!/bin/bash
#$ -N pacbio_final_canu_test
#$ -q class
#$ -pe openmp 32
#$ -m beas

module load samtools/1.9
module load bamtools/2.3.0
module load smrtanalysis/6.0.0
module load tbatarse/miniconda/3

mkdir assembly_Ecoli

cd assembly_Ecoli

cp /pub/tbatarse/Bioinformatics_Course/Final/prefixes.txt prefixes.txt

wget https://s3.amazonaws.com/files.pacb.com/datasets/secondary-analysis/e-coli-k12-8-plex/Ecoli_8plex_demo.barcoded.subreads.bam
wget https://s3.amazonaws.com/files.pacb.com/datasets/secondary-analysis/e-coli-k12-8-plex/Ecoli_8plex_demo.barcoded.subreads.bam.pbi
wget https://s3.amazonaws.com/files.pacb.com/datasets/secondary-analysis/e-coli-k12-8-plex/barcodes_8plex.fasta

lima Ecoli_8plex_demo.barcoded.subreads.bam barcodes_8plex.fasta Ecoli_8plex_demo.bam --split-bam

prefix=`head -n $SGE_TASK_ID prefixes.txt | tail -n 1 | cut -f2`

bamtools convert -format fastq -in ${prefix}.bam -out ${prefix}.fastq

module load canu/1.5

mkdir ${prefix}

canu \
 -p ${prefix}_ecoli_8plex -d ${prefix} \
 genomeSize=4.8m \
 -pacbio-raw ${prefix}x.fastq
