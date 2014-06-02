#!/bin/bash

STORM_NAME=$1
WORKD=/workspace/thesser1/WW3_ATL/outdat/
GETD=$CENTER/$STORM_NAME

#cp -rf $GETD $WORKD
echo 'Sending files to Halaiwa'
./ftp_out $STORM_NAME

#rm -rf $GETD
echo 'Archiving tgz files on MSF'
./archive_files.sh $STORM_NAME
