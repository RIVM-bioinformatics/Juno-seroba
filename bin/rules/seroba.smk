#############################################################################
##### De novo assembly                                                  #####
#############################################################################

rule download_seroba_db:
    output:
        audit = OUT + "/audit_trail/seroba_db.yaml"
    conda:
        "../../envs/seroba.yaml"
    threads: config["threads"]["download_db"]
    resources: mem_mb=config["mem_mb"]["download_db"]
    params:
        db_dir = config["seroba_db"],
        kmer_size = config["kmer_size"]
    log:
        OUT + "/log/serotype/download_seroba_db.log"
    shell:
        '''
if [ ! -f {params.db_dir}/log_seroba_db.yaml ];
then
    rm -rf {params.db_dir}
    bash bin/download_seroba_db.sh {params.db_dir} {params.kmer_size} &> {log}
fi

cp {params.db_dir}/log_seroba_db.yaml {output.audit} &> {log}
        '''

rule seroba:
    input:
        r1 = OUT + "/clean_fastq/{sample}_pR1.fastq.gz",        
        r2 = OUT + "/clean_fastq/{sample}_pR2.fastq.gz",
        db = OUT + "/audit_trail/seroba_db.yaml"
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
        seroba_db = config["seroba_db"]
    log:
        OUT + "/log/serotype/{sample}.log"
    shell:
        """
rm -rf {wildcards.sample} 
OUTPUT_DIR=$(dirname {output})
mkdir -p $OUTPUT_DIR

seroba runSerotyping --coverage {params.min_cov} {params.seroba_db}/database {input.r1} {input.r2} {wildcards.sample} &> {log}

mv {wildcards.sample}/* $OUTPUT_DIR

rm -rf {wildcards.sample}
        """