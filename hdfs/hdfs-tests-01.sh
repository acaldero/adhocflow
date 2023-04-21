#!/bin/sh
set -x


#
# Download...
#

echo "Download from HDFS..."
# Remove old "train*.tar.gz" files at $BASE_CACHE...
echo rm -fr  /mnt/local-storage/tmp/localhost
# Copy new files
echo hdfs/hdfs-cp.sh hdfs2local /daloflow/  ./list.txt  /mnt/local-storage/tmp/localhost


#
# Upload...
#

echo "Upload to HDFS..."
echo hdfs/hdfs-cp.sh local2hdfs /daloflow/dataset32x32 /mnt/local-storage/daloflow/dataset-cache/dataset32x32/list.txt /mnt/local-storage/daloflow/dataset32x32/


#
# List...
#

echo "List one HDFS directory..."
env CLASSPATH=$CLASSPATH:$(/mnt/local-storage/prueba-hdfs/hadoop/bin/hadoop classpath --glob) /mnt/local-storage/prueba-hdfs/hadoop/bin/hdfs dfs -ls /daloflow/dataset32x32/107

