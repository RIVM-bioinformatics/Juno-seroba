DB_DIR=$1
KMER_SIZE=$2

mkdir -p $DB_DIR

git clone --single-branch https://github.com/sanger-pathogens/seroba.git $DB_DIR

cd $DB_DIR

rm -rf seroba/scripts
rm -rf seroba/seroba

seroba createDBs database/ $KMER_SIZE

echo -e """
seroba_db:
    commit: https://github.com/sanger-pathogens/seroba/tree/$(git log -n 1 --pretty=format:"%H")
    timestamp: $(date)
""" > log_seroba_db.yaml