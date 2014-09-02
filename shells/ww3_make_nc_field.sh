#!/bin/bash

level=$1
gridloc=$2
STORM_NAME=$3
BASE=$4
BASIN=$5

WORKD=$BASE/outdat/$STORM_NAME

EXED=$BASE/exe
SHEL=$BASE/shells
INPD=$BASE/inputfiles
FCOD=$BASE/fcode
PYTH=$BASE/python_codes
yearmon=`echo $STORM_NAME | cut -c1-6`

cd $WORKD
lev=$level
echo $grd
dirn=$lev"-field"
cd $dirn
cp $INPD/grids/$gridloc/*$lev* .
/u/thesser1/anaconda/bin/python $PYTH/create_field_nc.py $yearmon $BASIN $lev
tarmax1=$STORM_NAME"_"$lev"_MMf.tgz"
tar -czf $tarmax1 wis*max_mean.nc
#rm wis*max_mean.nc
tarname1=$STORM_NAME"_"$lev"_field.tgz"
tar -czf $tarname1 wis*.nc
#tar -czf $tarname1 wis*.h5
mv *.tgz $WORKD
cd $WORKD
#rm -rf $dirn
