# Juno-seroba
Pipeline for serotyping Streptococcus pneumoniae (to be merged in Juno-typing).

Steps included:
  - Quality control of raw fastq files (FastQC)
  - Filtering and trimming of fastq files (Trimmomatic)
  - Quality control of "clean" fastq files (FastQC)
  - Serotyping (assuming samples are _S. pneumoniae_) (Seroba)

## Basic usage

1. Download this repository either directly from this website or using the following command in your preferred terminal while being in the location where you want the pipeline to be downloaded:

```
git clone https://github.com/RIVM-bioinformatics/Juno-seroba
```

2. Move to the directory containing the pipeline.

```
cd /path/to/Juno-seroba-master
```

3. Run the pipeline

```
bash juno-seroba /path/to/data/
```

Where /path/to/data/ should be a relative or absolute path to a directory containing fastq files. The fastq files CANNOT be in subdirectories and they should have a recognizable name (accepted extensions: .fastq, .fq. .fastq.gz or .fq.gz). Only paired data is accepted and each file should be recognized by having the \_R1_ or \_1_ in the file name of forward reads and \_R2_ or \_2_ in the file name of reverse reads.  

The results will 

## Advanced used

Please check the help for other parameters that can be changed. For instance, you can choose the output directory or change the path to the database (it will be automatically downloaded), etc. In order to see the arguments that can be changed, see the help:

```
bash juno-seroba -h
```

**Note:** If you would find any problems, please [contact me](mailto:alejandra.hernandez.segura@rivm.nl) directly or file an issue. 