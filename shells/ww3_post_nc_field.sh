#!/bin/bash

level=$1
gridloc=$2
STORM_NAME=$3
BASE=$4
BASIN=$5
UNIT=$6

WORKD=$BASE/outdat/$STORM_NAME

EXED=$BASE/exe
SHEL=$BASE/shells
INPD=$BASE/inputfiles
FCOD=$BASE/fcode

yearmon=`echo $STORM_NAME | cut -c1-6`

cd $WORKD
lev=$level
echo $grd
if [ $UNIT == 'ALL' ]
  then
    dirn=$lev"-field"
    outf="post_outf.sh"
else
    dirn=$lev"-field"$UNIT
    outf="post_outf"$UNIT".sh"
    dirsave=$lev"-field"
    mkdir $WORKD/$dirsave
fi

mkdir $dirn
moddef="mod_def."$lev
outgrd="out_grd."$lev
#outpnt="out_pnt."$lev
echo $moddef
cp $moddef $dirn/mod_def.ww3
cp $outgrd $dirn/out_grd.ww3
cp *.datesin $dirn
cd $dirn
#outf="post_outf_"$lev".sh"
$SHEL/$outf $STORM_NAME $BASE $WORKD/$dirn $lev
wait
#
mv $WORKD/$dirn/ww3.*.* $WORKD/$dirsave
#cp $INPD/grids/$gridloc/*$lev* .
#/u/thesser1/anaconda/bin/python /lustre/work1/thesser1/WIS_PAC/python_codes/create_field_hdf5.py $yearmon $BASIN $lev
#tarname1=$STORM_NAME"_"$lev"_field.tgz"
#tar -czf $tarname1 wis*.h5
#mv $tarname1 $WORKD
cd $WORKD
rm -rf $dirn
