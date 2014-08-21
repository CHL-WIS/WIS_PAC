#!/bin/bash

STORM_NAME=$1
BASE=$2
lev=$3

WKDIR=$BASE/outdat/$STORM_NAME/

levdir=$WKDIR/$lev
cd $levdir
tarname=$STORM_NAME"_"$lev"_wis_points.tgz"
tar -czf $tarname ST8*.nc
tarname=$STORM_NAME"_"$lev"_buoy_points.tgz"
tar -czf $tarname ST4*.nc ST5*.nc
mv $levdir/*.tgz $WKDIR
cd $WKDIR
#rm -rf $levdir    
