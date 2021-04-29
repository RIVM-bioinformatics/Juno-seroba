"""
Serotyper Seroba
Author: Alejandra Hernandez Segura
Organization: Rijksinstituut voor Volksgezondheid en Milieu (RIVM)
Department: Infektieziekteonderzoek, Diagnostiek en Laboratorium Surveillance (IDS), Bacteriologie (BPD)
Date: 26-04-2021
Documentation: https://github.com/RIVM-bioinformatics/Juno-seroba
"""

import argparse
import re
import yaml
import pathlib
import subprocess
import os
import snakemake
from uuid import uuid4
from datetime import datetime

fq_pattern = re.compile("(.*?)(?:_S\d+_|_S\d+.|_|\.)(?:p)?R?(1|2)(?:_.*\.|\..*\.|\.)f(ast)?q(\.gz)?")


def make_sample_sheet(input_dir, filename):
    """Function to make a sample sheet from the input directory"""

    assert input_dir.is_dir(), "The provided input directory ({})does not exist. Please make sure to provide an existing directory.".format(str(input_dir))

    print("A sample sheet with the samples to be processed will be created...")

    samples = {}
    for file_ in input_dir.iterdir():
        if file_.is_dir():
            continue
        match = fq_pattern.fullmatch(file_.name)
        if match:
            sample = samples.setdefault(match.group(1), {})
            sample["R{}".format(match.group(2))] = str(file_)
    
    with open(filename, "w") as sample_sheet:
        yaml.dump(samples, sample_sheet, default_flow_style=False)


def get_pipeline_log(filename):

    pipeline_log = {}
    pipeline_log['timestamp'] = str(datetime.now())
    pipeline_log['server_host'] = subprocess.check_output('hostname', shell = True)
    pipeline_log['pipeline_run_id'] = uuid4().hex
    try:
        pipeline_log['repo_version'] = subprocess.check_output('git log -n 1 --pretty=format:"%H"', shell = True)
    except subprocess.CalledProcessError:
        pipeline_log['repo_version'] = "NA"

    with open(filename, "w") as logfile:
        yaml.dump(pipeline_log, logfile, default_flow_style=False)


def get_resources(cores, queue):
    resources = {}
    resources['cores'] = cores
    if queue is None:
        resources['queue'] = os.getenv('irods_runsheet_sys__runsheet__lsf_queue')
        if resources['queue'] is None:
            resources['queue'] = 'bio'
    else:
        resources['queue'] = 'bio'
    return resources


# def check_databases(db_path):
#     assert db_path.is_dir(), "The provided path to the database ({})does not exist. Please make sure to provide an existing path.".format(str(db_path))


def main(args):
    get_pipeline_log("config/pipeline_log.yaml")
    make_sample_sheet(args.input, "config/sample_sheet.yaml")
    resources = get_resources(args.cores, args.queue)
    snakemake.snakemake("Snakefile",
                        workdir=pathlib.Path(__file__).parent.absolute(),
                        config={"out": str(args.output), "sample_sheet": "config/sample_sheet.yaml"},
                        cores=resources['cores'],
                        nodes=resources['cores'],
                        use_conda=True,
                        conda_frontend="mamba",
                        dryrun=args.dryrun,
                        jobname="seroba_{name}.jobid{jobid}",
                        keepgoing=True,
                        printshellcmds=True,
                        unlock=args.unlock,
                        configfiles=["config/pipeline_parameters.yaml"],
                        drmaa=" -q bio -n {threads} -o %s/log/drmaa/{name}_{wildcards}_{jobid}.out -e %s/log/drmaa/{name}_{wildcards}_{jobid}.err -R \"span[hosts=1]\" -R \"rusage[mem={resources.mem_mb}]\" " % (str(args.output), str(args.output))
                        )
    

if __name__ == '__main__':
    args = argparse.ArgumentParser()
    args.add_argument( 
        "input",
        type=pathlib.Path, 
        metavar = "DIR",
        help="Path to input directory where input fastq files are located."
        )
    args.add_argument(
        "-o",
        "--output",
        type=pathlib.Path,
        default="out",
        required=False,
        metavar="DIR",
        help="Path to desired output directory. If it does not exist, it will be created. If non is given the default will be an output directory in the main pipeline folder."
    )
    args.add_argument(
        "-q",
        "--queue",
        type=str,
        default=None,
        required=False,
        metavar="STR",
        help="Name of the queue to use if running in a computer cluster."
    )
    args.add_argument(
        "-c",
        "--cores",
        type=int,
        default=300,
        required=False,
        metavar="INT",
        help="Maximum number of cores to use while running the pipeline."
    )
    args.add_argument(
        "-u",
        "--unlock",
        action='store_true',
        help="Unlocking working directory (passed to snakemake)."
    )
    args.add_argument(
        "-n",
        "--dryrun",
        action='store_true',
        help="Dry run printing steps to be taken in the pipeline without actually running it (passed to snakemake)."
    )
    main(args.parse_args())
