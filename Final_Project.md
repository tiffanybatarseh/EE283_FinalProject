# Final Project: PacBio Sequencing of 8 E. coli Genomes from Single SMRT Cell

**The basic steps to get this assembly are:**

Download the data

Demultiplex the data

Convert from bam to fastq format

Check read quality

Canu for assembly of all 8 genomes

BUSCO to check for genome completeness

## Downloading the data

```
wget https://s3.amazonaws.com/files.pacb.com/datasets/secondary-analysis/e-coli-k12-8-plex/Ecoli_8plex_demo.barcoded.subreads.bam
wget https://s3.amazonaws.com/files.pacb.com/datasets/secondary-analysis/e-coli-k12-8-plex/Ecoli_8plex_demo.barcoded.subreads.bam.pbi
wget https://s3.amazonaws.com/files.pacb.com/datasets/secondary-analysis/e-coli-k12-8-plex/barcodes_8plex.fasta
```

The files that I dowloaded are the subreads.bam file which has all of the reads from that PacBio SMRT run. There are 8 different E. coli genomes in the file with their own unique barcodes. There is also a fasta file with the 8 different barcodes sequences listed out that can be used for demultiplexing. 

## Demultiplexing the data

This step took me several attempts to try and find the best method to demultiplex the data. I first found **lima** to try and use that to demultiplex the reads and split them by the barcodes. 

```
module load smrtanalysis/6.0.0
lima Ecoli_8plex_demo.barcoded.subreads.bam barcodes_8plex.fasta Ecoli_8plex_demo.bam --split-bam
```

There are other tools to demultiplex the data like **bam2fastx** through bioconda. I tried to install it: 

```
conda install -c bam2fastx
```

Couldn't get it to install and it actually only works with python2 and I only had miniconda with python 3 (miniconda3) installed and didn't want to go through the trouble of installing miniconda2 for this. Went back to lima... 

There is also bam2bam. I could not determine if it was available on the HPC. 

```
bam2bam --barcodes barcodes_8plex.fasta -o Ecoli_8plex_demo.barcoded.subreads.bam
```
Could not determine how to install onto HPC either. 
