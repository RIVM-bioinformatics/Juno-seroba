DB_DIR=$1

mkdir -p $DB_DIR

git clone --single-branch https://github.com/sanger-pathogens/seroba/commit/8138dc8713e4dec1a6a4379b91e20e4dc958160c $DB_DIR
rm -rf $DB_DIR/seroba/scripts
rm -rf $DB_DIR/seroba/seroba

seroba createDBs /mnt/db/seroba_db/database/ 71 # 71 is the recommended database in their repo (20-Apr-2021)