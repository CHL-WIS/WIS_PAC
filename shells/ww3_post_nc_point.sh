#!/bin/bash

level=$1
gridloc=$2
STORM_NAME=$3
BASE=$4
BASIN=$5
UNAME=$6

WORKD=$BASE/outdat/$STORM_NAME

EXED=$BASE/exe
SHEL=$BASE/shells
INPD=$BASE/inputfiles
FCOD=$BASE/fcode

yearmon=`echo $STORM_NAME | cut -c1-6`

cd $WORKD
lev=$level
#cd $WORKD/$lev
echo $grd
mkdir $lev
moddef="mod_def."$lev
outpnt="out_pnt."$lev
echo $moddef
cp $moddef $level/mod_def.ww3
cp $outpnt $level/out_pnt.ww3
cp *.datesin $level
cd $lev
# ----------------------------------------------------
#  Point Analysis
# ----------------------------------------------------
if [ ! -f out_pnt.ww3 ] 
  then
    mv *point.tgz $WORKD
    cd $WORKD
#    rm -rf $WORKD/$lev 
    exit 0
fi
outp="post_ounp.sh"
print $outp
$SHEL/$outp $STORM_NAME $BASE $WORKD/$lev $lev
/u/thesser1/anaconda/bin/python /lustre/work1/thesser1/WIS_PAC/python_codes/ww3_netcdf.py $yearmon $BASIN $lev $UNAME
tarname2=$STORM_NAME"_"$lev"_point.tgz"
tar -czf $tarname2 ST*.h5
mv $WORKD/$lev/*point.tgz $WORKD
