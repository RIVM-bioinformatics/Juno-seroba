#############################################################################
##### Scaffold analyses: QUAST, CheckM, picard, bbmap and QC-metrics    #####
#############################################################################

rule multiqc:
    input:
        expand(OUT + "/qc_raw_fastq/{sample}_{read}_fastqc.zip", sample = SAMPLES, read = "R1 R2".split()),
        expand(OUT + "/qc_clean_fastq/{sample}_{read}_fastqc.zip", sample = SAMPLES, read = "pR1 pR2".split())
    output:
        OUT + "/multiqc/multiqc.html",
    conda:
        "../../envs/fastqc_trimmomatic.yaml"
    benchmark:
        OUT + "/log/benchmark/multiqc.txt"
    threads: config["threads"]["multiqc"]
    resources: mem_mb=config["mem_mb"]["multiqc"]
    params:
        output_dir=OUT + "/multiqc"
    log:
        OUT + "/log/multiqc/multiqc.log"
    shell:
        """
multiqc -o {params.output_dir} \
-n multiqc.html {input} > {log} 2>&1
    """
