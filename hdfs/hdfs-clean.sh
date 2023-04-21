#!/bin/bash
set -x

#
# Get configuration
#

BASE_DIR=$(dirname "$0")
. $BASE_DIR/config.hdfs-clean

if [ ! -d "$BASE_CACHE" ]; then
        echo "Directory not found: $BASE_CACHE"
        exit
fi

#
# Copy files into a local directory ($BASE_CACHE + "container name")
#
BASE_CACHE_IN_CONTAINER=$BASE_CACHE"/"$(hostname)

# Remove old files at $BASE_CACHE...
rm -fr $BASE_CACHE_IN_CONTAINER

