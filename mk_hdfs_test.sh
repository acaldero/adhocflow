#!/bin/bash
set -x

BASE_HDFS=/daloflow/
LIST_CACHE=hdfs/list.txt
BASE_CACHE=/mnt/local-storage/tmp/$(hostname)

DATASETS="dataset32x32 dataset64x64 dataset128x128 dataset256x256 dataset512x512"
for DS in $DATASETS; do

    echo $DS

    zcat hdfs/$DS.list.txt.gz  > $LIST_CACHE
    ./hdfs/hdfs-cp.sh $BASE_HDFS $LIST_CACHE $BASE_CACHE
    ./hdfs/hdfs-cp.sh $BASE_HDFS $LIST_CACHE $BASE_CACHE

    rm -fr $BASE_CACHE
    sync

done

