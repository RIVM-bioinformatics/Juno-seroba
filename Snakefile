"""
Seroba pipeline
Authors: Alejandra Hernandez-Segura
Organization: Rijksinstituut voor Volksgezondheid en Milieu (RIVM)
Department: Infektieziekteonderzoek, Diagnostiek en Laboratorium Surveillance (IDS), Bacteriologie (BPD)
Date: 26-04-2021

Documentation:  https://github.com/RIVM-bioinformatics/Juno-seroba


Snakemake rules (in order of execution):
    1 fastQC        # Asses quality of raw reads.
    2 trimmomatic   # Trim low quality reads and adapter sequences.
    3 fastQC        # Asses quality of trimmed reads.
    4 seroba        # Serotyping Streptococcus pneumoniae

"""

#################################################################################
##### Import config file, sample_sheet and set output folder names          #####
#################################################################################

import pathlib
import pprint
import os
import yaml
import json

#################################################################################
##### Load samplesheet, load genus dict and define output directory         #####
#################################################################################

# SAMPLES is a dict with sample in the form sample > read number > file. E.g.: SAMPLES["sample_1"]["R1"] = "x_R1.gz"
SAMPLES = {}
with open(config["sample_sheet"]) as sample_sheet_file:
    SAMPLES = yaml.safe_load(sample_sheet_file) 

# OUT defines output directory for most rules. 
OUT = config["out"]

#@#############################################################################
#@#### 				            Processes                                 #####
#@#############################################################################

    ###########################################################################
    ##### Data quality control and cleaning                               #####
    ###########################################################################
include: "bin/rules/fastqc_raw_data.smk"
include: "bin/rules/trimmomatic.smk"
include: "bin/rules/fastqc_clean_data.smk"
include: "bin/rules/multiqc.smk"

    ###########################################################################
    ##### Seroba serotyping                                               #####
    ###########################################################################
include: "bin/rules/seroba.smk"

#@#############################################################################
#@####   Loggings before/after pipeline                                   #####
#@#############################################################################

onstart:
    try:
        print("Checking if all specified files are accessible...")
        important_files = [ config["sample_sheet"],
                                'files/trimmomatic_0.36_adapters_lists/NexteraPE-PE.fa' ]
        for filename in important_files:
            if not os.path.exists(filename):
                raise FileNotFoundError(filename)
    except FileNotFoundError as e:
        print("This file is not available or accessible: %s" % e)
        sys.exit(1)
    else:
        print("\tAll specified files are present!")
    shell("""
        mkdir -p {OUT}
        mkdir -p {OUT}/audit_trail
        echo -e "\nLogging pipeline settings..."
        echo -e "\tGenerating methodological hash (fingerprint)..."
        #TODO add the proper link to the repo
        #echo -e "This is the link to the code used for this analysis:\thttps://github.com/RIVM-bioinformatics/Juno-seroba/tree/$(git log -n 1 --pretty=format:"%H")" > '{OUT}/audit_trail/log_git.txt'
        echo -e "This code with unique fingerprint $(git log -n1 --pretty=format:"%H") was committed by $(git log -n1 --pretty=format:"%an <%ae>") at $(git log -n1 --pretty=format:"%ad")" >> '{OUT}/audit_trail/log_git.txt'
        echo -e "\tGenerating full software list of current conda environment..."
        conda list > '{OUT}/audit_trail/log_conda.txt'
        echo -e "\tGenerating config file log..."
        rm -f '{OUT}/audit_trail/log_config.txt'
        touch '{OUT}/audit_trail/log_config.txt'
        for file in config/*.yaml
        do
            echo -e "\n==> Contents of file \"${{file}}\": <==" >> '{OUT}/audit_trail/log_config.txt'
            cat ${{file}} >> '{OUT}/audit_trail/log_config.txt'
            echo -e "\n\n" >> '{OUT}/audit_trail/log_config.txt'
        done
    """)

#onerror:
#   shell("""""")


onsuccess:
    shell("""
        rm -rf temp.*
        echo -e "\tGenerating Snakemake report..."
        snakemake --config out={OUT} sample_sheet="config/sample_sheet.yaml" --configfile "config/pipeline_parameters.yaml" --cores 1 --unlock
        snakemake --config out={OUT} sample_sheet="config/sample_sheet.yaml" --configfile "config/pipeline_parameters.yaml" --cores 1 --report '{OUT}/audit_trail/snakemake_report.html'
        echo -e "Finished"
    """)


###############################################################################
##### Specify final output:                                               #####
###############################################################################

localrules:
    all


rule all:
    input:
        expand(OUT + "/qc_raw_fastq/{sample}_{read}_fastqc.zip", sample = SAMPLES, read = ['R1', 'R2']),   
        expand(OUT + "/clean_fastq/{sample}_{read}.fastq.gz", sample = SAMPLES, read = ['pR1', 'pR2', 'uR1', 'uR2']),
        expand(OUT + "/qc_clean_fastq/{sample}_{read}_fastqc.zip", sample = SAMPLES, read = ['pR1', 'pR2']),
        expand(OUT + "/serotype/{sample}/pred.tsv", sample = SAMPLES),   
        OUT + "/multiqc/multiqc.html"
