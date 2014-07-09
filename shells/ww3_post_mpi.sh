#!/bin/bash

level=$1
STORM_NAME=$2
BASE=$3
BASIN=$4
UNAME=$5

WORKD=$BASE/outdat/$STORM_NAME

EXED=$BASE/exe
SHEL=$BASE/shells
INPD=$BASE/inputfiles
FCOD=$BASE/fcode

yearmon=`echo $STORM_NAME | cut -c1-6`
#level[1]="LEVEL1"
#level[2]="LEVEL2"
#level[3]="LEVEL3N"
#level[4]="LEVEL3C"
#level[5]="LEVEL3S1"
#level[6]="LEVEL3S2"

cd $WORKD
#for ii in {1..6}
#do
#lev=${level[ii]}
lev=$level
#grd='grd'$ii
echo $grd
mkdir $lev
moddef="mod_def."$lev
outgrd="out_grd."$lev
outpnt="out_pnt."$lev
echo $moddef
cp $moddef $level/mod_def.ww3
cp $outgrd $level/out_grd.ww3
cp $outpnt $level/out_pnt.ww3
cp *.datesin $lev
cd $lev
outf="post_outf_"$lev".sh"
$SHEL/$outf $STORM_NAME $BASE $WORKD/$lev
#
python create_field_hdf5.py $yearmon $BASIN $lev $UNAME
tarname1=$STORM_NAME"_"$lev"_field.tgz"
tar -czf $tarname1 wis*.h5

#ls -1 *_sea > fort.15

#wsep="wsep_points.x"
#ln $INPD/*$grd*.grd $WORKD/$lev
#ls -1 *$grd*.grd > fort.5
#$FCOD/$wsep < fort.5
#
#stname=`echo $STORM_NAME | cut -c1-6 `
#name1=$STORM_NAME"-"$lev"-hss.tgz"
#name2=$STORM_NAME"-"$lev"-sea.tgz"
#name3=$STORM_NAME"-"$lev"-sw1.tgz"
#name4=$STORM_NAME"-"$lev"-sw2.tgz"
#name5=$STORM_NAME"-"$lev"-sep.tgz"
#name6=$STORM_NAME"-"$lev"-wnd.tgz"
#name7=$STORM_NAME"-"$lev"-MMt.tgz"
#name8=$STORM_NAME"-"$lev"-hdr.tgz"
#
#tar -czf $name1 *.hs
#tar -czf $name2 *_sea
#tar -czf $name3 *_sw1
#tar -czf $name4 *_sw2
#tar -czf $name5 *.sep
#tar -czf $name6 *.wnd
#tar -czf $name7 Max*
#tar -czf $name8 *.dir
##
#rm -rf *.hs
#rm -rf *_sea
#rm -rf *_sw1
#rm -rf *_sw2
#rm -rf *.sep
#rm -rf *.wnd
#rm -rf Max*
#rm -rf *.dir
#
# ----------------------------------------------------
#  Point Analysis
# ----------------------------------------------------
if [ ! -f out_pnt.ww3 ] 
  then
    mv *.tgz $WORKD
    cd $WORKD
    rm -rf $WORKD/$lev 
    exit 0
fi
#cp $outpnt $lev/out_pnt.ww3
outp="post_ounp_"$lev".sh"
echo $outp
$SHEL/$outp $STORM_NAME $BASE $WORKD/$lev
python ww3_netcdf.py $yearmon $BASIN $lev $UNAME
tarname2=$STORM_NAME"_"$lev"_point.tgz"
tar -cvf $tarname2 ST*.h5
#
#locs="Output_Locs_"$grd".txt"
#cp $INPD/$locs $WORKD/Output_Locs.txt
#$FCOD/point_onlns_ww3.x
#
#ls -1 *.spc > fort.2
#
#$FCOD/spec_onlns_ww3.x
#namew=$STORM_NAME"-"$lev"-ST-onlns.tgz"
#namep=$STORM_NAME"-"$lev"-onlns.tgz"
#names=$STORM_NAME"-"$lev"-spec.tgz"
#nameb=$STORM_NAME"-"$lev"-spec-buoy.tgz"

#tar -czf $namew ST*.onlns
#rm -rf ST*.onlns
#
#tar -czf $namep *.onlns
#tar -czf $names *.spc

#$FCOD/ww3_spec_conf.x
#tar -czf $nameb *.spe2d
#rm -rf *.spe2d
#
#done
#
mv $WORKD/$lev/*.tgz $WORKD
#cd $WORKD
#rm -rf $WORKD/$lev
