#!/bin/bash

STORM_NAME=$1
BASE=$2
lev=$3

WKDIR=$BASE/outdat/$STORM_NAME/

levdir=$WKDIR/$lev
cd $levdir
tarname=$STORM_NAME"_"$lev"_points.tgz"
tar -czf $tarname *.h5
mv $levdir/*.tgz $WKDIR
cd $WKDIR
rm -rf $levdir    
