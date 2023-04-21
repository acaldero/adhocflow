#!/bin/sh
set -x


LOCAL_CACHE_PATH=/mnt/local-storage/tmp/localhost
DALOFLOW_BASE_PATH=/mnt/local-storage/daloflow
HADOOP_CLASS_PATH=$(/mnt/local-storage/prueba-hdfs/hadoop/bin/hadoop classpath --glob)
HADOOP_BASE_PATH=/mnt/local-storage/prueba-hdfs/hadoop


#
# Download...
#

echo "Download from HDFS..."
# Remove old "train*.tar.gz" files at $BASE_CACHE...
echo rm -fr  $(LOCAL_CACHE_PATH)
# Copy new files
echo scripts/hdfs/hdfs-cp.sh hdfs2local /daloflow/  ./list.txt  $(LOCAL_CACHE_PATH)


#
# Upload...
#

echo "Upload to HDFS..."
echo scripts/hdfs/hdfs-cp.sh local2hdfs /daloflow/dataset32x32 ${DALOFLOW_BASE_PATH}/dataset-cache/dataset32x32/list.txt ${DALOFLOW_BASE_PATH}/dataset32x32/


#
# List...
#

echo "List one HDFS directory..."
env CLASSPATH=${CLASSPATH}:${HADOOP_CLASS_PATH} ${HADOOP_BASE_PATH}/bin/hdfs dfs -ls /daloflow/dataset32x32/107

