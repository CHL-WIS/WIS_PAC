#!/bin/bash
sta=$1
sto=$2
setn=$3
level=$4
gridloc=$5
STORM_NAME=$6
BASE=$7
BASIN=$8
UNAME=$9

WORKD=$BASE/outdat/$STORM_NAME

EXED=$BASE/exe
SHEL=$BASE/shells
INPD=$BASE/inputfiles
FCOD=$BASE/fcode
PYTH=$BASE/python_codes
yearmon=`echo $STORM_NAME | cut -c1-6`

cd $WORKD
lev=$level
if [ ! -d $lev ]
  then
    mkdir $lev
fi
#cd $WORKD/$lev
echo $grd
dirn=$lev"-point"$setn
echo $moddef
cd $dirn
# ----------------------------------------------------
#  Point Analysis
# ----------------------------------------------------
/u/thesser1/anaconda/bin/python $PYTH/ww3_netcdf.py $yearmon $BASIN $level-$setn
wait
mv $WORKD/$dirn/ST*.nc $WORKD/$lev
cd $WORKD
#rm -rf $dirn
#tarname2=$STORM_NAME"_"$lev"_point_set"$setn".tgz"
#tar -czf $tarname2 ST*.h5
#mv $WORKD/$dirn/*point.tgz $WORKD/$lev
