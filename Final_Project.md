# Final Project: PacBio Sequencing of 8 E. coli Genomes from Single SMRT Cell

**The basic steps to get the assemblies are:**

Download the data

Demultiplex the data

Convert from bam to fastq format

Check read quality

Canu for assembly of all 8 genomes

BUSCO to check for genome completeness

## Relevant modules used on HPC

```
module load bamtools/2.3.0
module load smrtanalysis/6.0.0
module load canu/1.5
```

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

I continued to the following steps with the demultiplexed data that Lima provided. 

## Convert from BAM format to fastq

Bam tools can be used to convert the format. Canu needs fastq files for assembly as input. 

```
bamtools convert -format fastq -in ${prefix}.bam -out ${prefix}.fastq
```

## Assembly with Canu

Canu is able to assemble genomes sequenced with long read technology. Canu has the ability to correct the reads, trim the reads, and assemble the reads. There is a way to implement all 3 of these commands with one command which is what I will use. Since there are 8 demultiplexed genomes, this job can be run as a task array in the HPC. I generated a prefixes text file in order to do so. 

General command for the canu assembly.

```
canu \
 -p ecoli_${prefix} -d ${prefix} \
 genomeSize=4.8m \
 -pacbio-raw ${prefix}.fastq
 ```
 
 The first time I ran this, I had an error occur that did not allow canu to proceed. The error said: 
 
 ```
 Detected Sun Grid Engine in '/opt/gridengine/default'.
--
-- WARNING:  Couldn't determine the SGE parallel environment to run multi-threaded codes.

-- WARNING:  Couldn't determine the SGE resource to request memory.
-- WARNING:  Valid choices are (pick one and supply it to canu):
-- WARNING:    gridEngineMemoryOption="-l fa_size=MEMORY"
-- WARNING:    gridEngineMemoryOption="-l mem_requested=MEMORY"
-- WARNING:    gridEngineMemoryOption="-l scratch_size=MEMORY"
--
================================================================================
Don't panic, but a mostly harmless error occurred and Canu stopped.

Canu release v1.5 failed with:
  can't configure for SGE
  ```
 
 
So, with some searching I added a line to the code to try and supply canu with the correct information to let it work as a task array.
 
```
gridEngineMemoryOption="-l h_vmem=MEMORY" gridEngineThreadsOption="-pe openmp 8"
```

But that did not work. Received following error message:
 
```
canu release v1.5 failed with:
  Couldn't parse gridEngineThreadsOption='-pe openmp-class 8'
```

Tried running it one genome at a time.

```
#!/bin/bash
#$ -N pacbio_final_one
#$ -q class
#$ -pe openmp 8
#$ -m beas

module load canu/1.5

mkdir Ecoli_8plex_demo.0--0_test
canu \
 -p Ecoli_8plex_demo.0--0 -d Ecoli_8plex_demo.0--0_test \
 genomeSize=4.8m \
 -pacbio-raw Ecoli_8plex_demo.0--0.fastq
```

Recieved same error message as before in which canu couldn't configure the SGE parallel environment even though I did not run it as a task array.

Added these options to the canu command

```
gridEngineThreadsOption="-pe openmp-class THREADS" gridEngineMemoryOption="-l mem_requested=8
```

New error:

```
/var/spool/sge/compute-13-7/job_scripts/6080918: line 10: unexpected EOF while looking for matching `"'
/var/spool/sge/compute-13-7/job_scripts/6080918: line 14: syntax error: unexpected end of file
```
