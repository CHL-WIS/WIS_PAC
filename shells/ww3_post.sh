#!/bin/bash

STORM_NAME=$1
BASE=$2
#BASE=/work/thesser1/WW3_ATL
WORKD=$BASE/outdat/$STORM_NAME

EXED=$BASE/exe
SHEL=$BASE/shells
INPD=$BASE/inputfiles
FCOD=$BASE/fcode

level[1]="LEVEL1"
level[2]="LEVEL2"
level[3]="LEVEL3N"
level[4]="LEVEL3C"
level[5]="LEVEL3S1"
level[6]="LEVEL3S2"

cd $WORKD
for ii in {1..6}
do
lev=${level[ii]}
grd='grd'$ii
echo $grd
moddef="mod_def."$grd
outgrd="out_grd."$grd
outpnt="out_pnt."$grd
echo $moddef
cp $moddef mod_def.ww3
cp $outgrd out_grd.ww3
cp *.datesi

outf="post_outf_"$lev".sh"
$SHEL/$outf $STORM_NAME $BASE $WORKD
#
ls -1 *_sea > fort.15

wsep="wsep_points.x"
ln $INPD/*$lev*.grd $WORKD
ls -1 *$lev*.grd > fort.5
$FCOD/$wsep < fort.5
#
stname=`echo $STORM_NAME | cut -c1-6 `
name1=$STORM_NAME"-"$lev"-hss.tgz"
name2=$STORM_NAME"-"$lev"-sea.tgz"
name3=$STORM_NAME"-"$lev"-sw1.tgz"
name4=$STORM_NAME"-"$lev"-sw2.tgz"
name5=$STORM_NAME"-"$lev"-sep.tgz"
name6=$STORM_NAME"-"$lev"-wnd.tgz"
name7=$STORM_NAME"-"$lev"-MMt.tgz"
name8=$STORM_NAME"-"$lev"-hdr.tgz"
#
tar -czf $name1 *.hs
tar -czf $name2 *_sea
tar -czf $name3 *_sw1
tar -czf $name4 *_sw2
tar -czf $name5 *.sep
tar -czf $name6 *.wnd
tar -czf $name7 Max*
tar -czf $name8 *.dir
#
rm -rf *.hs
rm -rf *_sea
rm -rf *_sw1
rm -rf *_sw2
rm -rf *.sep
rm -rf *.wnd
rm -rf Max*
rm -rf *.dir
#
# ----------------------------------------------------
#  Point Analysis
# ----------------------------------------------------
if [ ! -f $outpnt ] 
  then 
    continue
fi
cp $outpnt out_pnt.ww3
outp="post_outp_"$lev".sh"
echo $outp
$SHEL/$outp $STORM_NAME $BASE $WORKD
#
#locs="Output_Locs_"$grd".txt"
#cp $INPD/$locs $WORKD/Output_Locs.txt
#$FCOD/point_onlns_ww3.x
#
ls -1 *.spc > fort.2
#
$FCOD/spec_onlns_ww3.x
namew=$STORM_NAME"-"$lev"-ST-onlns.tgz"
namep=$STORM_NAME"-"$lev"-onlns.tgz"
names=$STORM_NAME"-"$lev"-spec.tgz"
nameb=$STORM_NAME"-"$lev"-spec-buoy.tgz"

tar -czf $namew *ST*.onlns
rm -rf *ST*.onlns
#
tar -czf $namep *.onlns
tar -czf $names *.spc

$FCOD/ww3_spec_conf.x
tar -czf $nameb *.spe2d
rm -rf *.spe2d
#
done
#
