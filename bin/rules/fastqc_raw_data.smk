#############################################################################
##### Data quality control and cleaning                                 #####
#############################################################################

rule qc_raw_fastq:
    input:
        lambda wildcards: SAMPLES[wildcards.sample][wildcards.read]
    output:
        html = OUT + "/qc_raw_fastq/{sample}_{read}_fastqc.html",
        zip = OUT + "/qc_raw_fastq/{sample}_{read}_fastqc.zip"
    conda:
        "../../envs/fastqc_trimmomatic.yaml"
    benchmark:
        OUT + "/log/benchmark/qc_raw_fastq_{sample}_{read}.txt"
    threads: config["threads"]["fastqc"]
    resources: mem_mb=config["mem_mb"]["fastqc"]
    log:
        OUT + "/log/qc_raw_fastq/qc_raw_fastq_{sample}_{read}.log"
    params:
        output_dir = OUT + "/qc_raw_fastq" 
    shell:
        """
mkdir -p {params.output_dir}/{wildcards.sample}_{wildcards.read}

fastqc --outdir {params.output_dir}/{wildcards.sample}_{wildcards.read} {input} &> {log}

mv {params.output_dir}/{wildcards.sample}_{wildcards.read}/*.html {output.html}
mv {params.output_dir}/{wildcards.sample}_{wildcards.read}/*.zip {output.zip}

rm -r {params.output_dir}/{wildcards.sample}_{wildcards.read}
        """
