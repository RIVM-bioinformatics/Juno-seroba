#############################################################################
##### De novo assembly                                                  #####
#############################################################################

rule seroba:
    input:
        r1=OUT + "/clean_fastq/{sample}_pR1.fastq.gz",        
        r2=OUT + "/clean_fastq/{sample}_pR2.fastq.gz"
    output:
        OUT + "/serotype/{sample}/pred.tsv"
    conda:
        "../../envs/seroba.yaml"
    benchmark:
        OUT + "/log/benchmark/seroba_{sample}.txt"
    threads: config["threads"]["seroba"]
    resources: mem_mb=config["mem_mb"]["seroba"]
    params:
        min_cov = config["min_cov"],
        seroba_db = config["db_dir"]
    log:
        OUT + "/log/serotype/{sample}_de_novo_assembly.log"
    shell:
        """
rm -rf {wildcards.sample} 
OUTPUT_DIR=$(dirname {output})
mkdir -p $OUTPUT_DIR

seroba runSerotyping --coverage {params.min_cov} {params.seroba_db} {input} {wildcards.sample} &> {log}

mv {wildcards.sample}/* $OUTPUT_DIR

rm -rf {wildcards.sample}
        """