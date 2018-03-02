# dockstore_tool_arriba

**This repository contains code to create a docker implementation of the arriba structural variant finding tool.**

Arriba was developed by Sebastian Uhrig and can be found at https://github.com/suhrig/arriba.
It is a tool to find structural variants (especially fusions) in RNASeq sample pairs, usually a tumor and control from one patient.

In a comparative analysis of fusion finder programs (see https://www.synapse.org/#!Synapse:syn2813589/wiki/401435), 
arriba consistently performed better than most other callers tested.

At the time of writing, arriba and the DREAM challenge have not yet been published. If you run this software and publish the results,
please find the correct reference for arriba.

**Inputs** to the program are a tumor/control pair of fastq files and several helper files (see below).
**Output** is a file with fusions, each with supporting information and a confidence score.


## The code

Please see http://arriba.readthedocs.io for detailed information about arriba. 

## Getting the docker container

Note that the arriba author provides a Dockerfile in the original arriba repository at  https://github.com/suhrig/arriba.
The Dockerfile in `BD2KGenomics/dockstore_tool_arriba` differs in that it uses a slightly altered run script, making it
compatible with running via a Common Workflow Language file also present in this directory.
*The settings for STAR and arriba have not been altered from the original* except for the `--limitBAMsortRAM` memory parameter
in STAR (the original setting led to core dumps in some cases).

The latest ADTEX docker image can be downloaded directly from quay.io using
`docker pull quay.io/ucsc_cgl/arriba`

Alternatively, you can build from the github repo:
```
git clone https:/github.com/BD2KGenomics/dockstore_tool_arriba
cd dockstore_tool_arriba
docker build -t arriba .
```

## Running the docker container

For details on running docker containers in general, see the excellent tutorial at https://docs.docker.com/

To see a usage statement, run

``
docker run arriba
``

### Example input:

``
docker run --log-driver=none -v /path/to/input/files:/data arriba run_arriba -a <genome.fa> -b <hg38|hg19> -g <annotation gtf> -k <known fusions list> -s <star index directory> -o <outputdir> -T <threads> -f <read1.fastq.gz> -r <read2.fastq.gz>
``

where

`read1.fastq.gz` and `read2.fastq.gz`	are (gzipped) fastq format files of RNA-Seq reads aligned to the genome. The arriba run script will run the aligner program STAR with settings specifically designed for arriba. You can submit unzipped fastq files as well.

`genome.fa`	is the genome (version) in (optionally gzipped) fasta format. The program expects this genome to be either hg19 (GRCHh37) or hg38 (GRCh38 (see blacklist below)

`hg38` or `hg19`	is used to determine which of the (arriba supplied) blacklists to use.

`annotation.gtf`	is the (optionally gzipped) [Gencode genome annotation](https://www.gencodegenes.org/releases/current.html) file for the sequence above.

`known fusions list`	is a list of paired gene names that occur in the annotation GTF file. To obtain this list, follow instructions at [readthedocs] (http://arriba.readthedocs.io/en/latest/input-files/). **NOTE**: You will have to register with Cosmic to obtain the list, and will not have permissions to redistribute it. This is why the list is not provided with this code, or with arriba itself.

`star index directory`	are [all the files](http://labshare.cshl.edu/shares/gingeraslab/www-data/dobin/STAR/STARgenomes/GENCODE/) necessary to run STAR. You can submit this as a directory, but if you run through CWL, a tar.gz file is expected. **NOTE**: 

`outputdir`	is optional; it will be created if it doesn't exist.

`threads`	is the number of processors the program is allowed to use.


### Output

Arriba and STAR output several files. Only arriba's `fusions.tsv` is retained here.

Note that the fusions file lists a `confidence` in field 15, which can be 'high', 'low', or 'medium'. Please take this information into account when determining which calls to trust.
Generally, fusion calling programs will find a number of false positives. It is therefore advised to run arriba on cohorts (for instance, a group of BRCA patients) and see which fusions show up multiple times. In addition, it may be advisable to run a separate fusion caller.

## Running from the command line

the `run_arriba` script is written specifically for the docker container. However, it is possible to call both STAR and arriba on the docker container without going through the script:

```
docker run --log-driver=none -v /path/to/input/files:/data arriba STAR <options>
docker run --log-driver=none -v /path/to/input/files:/data arriba /opt/arriba_v0.12.0/arriba <options>
```
Either progam will give you a usage statement with the options to supply.

If you want to run arriba from the commandline, please download it [from the original source](https://github.com/suhrig/arriba)

## Running via CWL

The [Common Workflow Language](http://www.commonwl.org/user_guide/) is a method to use the same tools on different platforms. 
The script provided here expects to find the arriba docker image on quay.io. To run it, you need a CWL runner and a
JSON format file with the inputs to `run_arriba`. The code in this
github repository was written specifically for [Dockstore](https://dockstore.org/) but it can be used on any other cwl-compatible platform.

To use with dockstore:
```
dockstore tool launch --entry quay.io/ucsc_cgl/dockstore_tool_arriba --json my.json
```
To create a ready to fill JSON example input, run 
```
dockstore tool convert cwl2json --cwl quay.io/ucsc_cgl/dockstore_tool_arriba > fillme.json
```
