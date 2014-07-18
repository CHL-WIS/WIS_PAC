#!/bin/bash
#
# ---------------------------------------------------------------
#
#   Script for running WW3 in Pacific domain for WIS test
#
#   written 06/03/11 TJ Hesser
#
#
# ---------------------------------------------------------------
#
UNAME='Tyler J. Hesser'
BASIN='pac'
BASE=$WORKDIR/WIS_PAC
OUTD=$BASE/outdat
INPF=$BASE/inputfiles
SHEL=$BASE/shells
WIND=$INPF/winds/
#WIND=$BASE/winds/CFSR
FCOD=$BASE/fcode
EXED=$BASE/exe
#
#
# Go to winds directory and generate file with all winds 
#
#
cd $WIND
ls -1 *PacDomain.win > $SHEL/windlist.tmp
#ls -1 *.win > $SHEL/windlist.tmp
#
# Go to shells directory and find winds to run
#
cd $SHEL
cat windlist.tmp | while read WINDS
do 
  echo $WINDS
  if grep $WINDS donelist
  then
    :
  else
    echo $WINDS >> torunlist.tmp
  fi 
done
#
#
cat torunlist.tmp | while read WINDS
 do 
   sleng="${#WINDS}"
   let "suse = $sleng - 4"
   FILESZ=`ls -l $WIND/$WINDS | awk '{printf "%s", $5} '  `
   STORMTMP=`echo $WINDS | cut -c1-$suse `
   echo $STORMTMP >> stormlist
done
#
#  Remove the temporary FILES
#
rm ${SHEL}/windlist.tmp
rm ${SHEL}/torunlist.tmp
#
#
# --------------------------------------------------------------
# --------------------------------------------------------------
#  Loop to run storms 
# --------------------------------------------------------------
#
cd $SHEL
File="stormlist"
exec 3<&0
exec 0<"$File"
read STORM_NAME2
#STN=`echo $STORM_NAME2 | cut -c1-4 `
STN=`echo $STORM_NAME2 | cut -c1-6 `
#year=`echo $STORM_NAME2 | cut -c1`
STORM_NAME="${STN}_WIS_PAC_WW3_OWI_ST4"
#if [ $year == '9' ] 
# then
#  STORM_NAME="19${STN}_WIS_ATL_WW3_OWI_ST4"
#elif [ $year == '8' ]
# then
#  STORM_NAME="19${STN}_WIS_ATL_WW3_OWI_ST4"
#else
#  STORM_NAME="20${STN}_WIS_ATL_WW3_OWI_ST4"
#fi
RUN_NAME=`echo $STORM_NAME | cut -c1-6 `
WORKDIR=`echo $OUTD/$STORM_NAME `
if [ ! -d $WORKDIR ]
  then 
   mkdir $WORKDIR
else
   echo `date` ${STORM_NAME} HAS ALREADY BEEN PROCESSED >> ${SHEL}/failog
   exit 0
fi
#
WINDPROC=`echo ${STORM_NAME2}.win `
#WINDPROC=`echo ${STORM_NAME2}.WIN `
#WINDPROC=`echo ${STORM_NAME2}.win `
#
if [ -f ${WIND}/${WINDPROC} ]
then
cd $WORKDIR
#
#  Move grids and make ww3_grid.inp
#  Run ww3_grid
$SHEL/genscript_basin_l1.sh $INPF $WORKDIR $EXED
#
#
#  NEW:  READING WIND FILE and CONSTRUCTING THE FLAT ASCII File for WW3.
#        Making the dates  
#
ln -sf $WIND/$WINDPROC $WORKDIR/fort.2
#
$FCOD/preproc_wnd_WW3.x
#
mv fort.20 ${WORKDIR}/${STORM_NAME}.datesin
cp fort.12 ${WORKDIR}/${STORM_NAME}.wnd
rm fort.2
#
#  Generate the ww3_prep.inp file
#  Run ww3_prep
$SHEL/genscript_prep_basin.sh $WORKDIR $EXED
#   
cp mod_def.ww3 mod_def.inp_basin
mv mod_def.ww3 mod_def.basin_l1
mv wind.ww3 wind.inp_basin
#
wind3a=` echo $WINDPROC | cut -c1-6 `
wind2a=` echo $WINDPROC | cut -c1-15 `
wind2=$wind2a"WestCoastDomain.win"
echo $wind2
ln -sf $WIND/$wind2 $WORKDIR/fort.2
$FCOD/preproc_wnd_WW3.x
cp fort.12 ${WORKDIR}/${STORM_NAME}-westc.wnd
rm fort.2
$SHEL/genscript_westc_l2.sh $INPF $WORKDIR $EXED
$SHEL/genscript_prep_westc.sh $WORKDIR $EXED
cp mod_def.ww3 mod_def.inp_westc
mv mod_def.ww3 mod_def.westc_l2
mv wind.ww3 wind.inp_westc
#
$SHEL/genscript_westc_l3.sh $INPF $WORKDIR $EXED
mv mod_def.ww3 mod_def.westc_l3
#
wind3=$wind3a"_SoCal.Win"
echo $wind3
ln -sf $WIND/$wind3 $WORKDIR/fort.2
$FCOD/preproc_wnd_WW3.x
cp fort.12 ${WORKDIR}/${STORM_NAME}-cali.wnd
rm fort.2
$SHEL/genscript_cali_l4.sh $INPF $WORKDIR $EXED
$SHEL/genscript_prep_cali.sh $WORKDIR $EXED
mv mod_def.ww3 mod_def.cali_l4
mv wind.ww3 wind.cali_l4
#
$SHEL/genscript_hawaii_l2.sh $INPF $WORKDIR $EXED
mv mod_def.ww3 mod_def.hawaii_l2
#
$SHEL/genscript_hawaii_l3.sh $INPF $WORKDIR $EXED
mv mod_def.ww3 mod_def.hawaii_l3
#
rm *.grd *.mask *.obstr
$SHEL/genscript_multi.sh $STORM_NAME $WORKDIR
$SHEL/genscript_sub.sh $STORM_NAME $RUN_NAME $BASE

echo $WINDPROC >> $SHEL/donelist

else
echo `date` Wind Field $WINDPROC DOES NOT EXIST >> $SHEL/stormlog
fi
rm -f $SHEL/stormlist
exit 0


