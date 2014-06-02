#!/bin/bash

STORM=$1
BASE=/workspace/thesser1/WW3_ATL/outdat
BASED=$BASE/$STORM
ARC=/erdc1/thesser1/ERDCV03995SHS/ATL
ARCD=$ARC/$STORM
ARCD2=gold.erdc.hpc.mil:$ARCD
if [ -d $BASED ] 
then
cd $BASED
tarname=$STORM"_mod.tgz"
#tar -czvf $tarname mod_def.grd* out_grd.grd* out_pnt.grd*

#if [ ! -d $ARC ] 
#then 
#archive mkdir -p $ARC
#rsh -l thesser1 gold.erdc.hpc.mil mkdir /erdc1/thesser1/ERDCV03995SHS/ATL/$ARC
#fi
echo $ARCD
rsh -l thesser1 gold.erdc.hpc.mil mkdir $ARCD
#archive mkdir -p $ARCD
echo $ARCD2
scp *.tgz $ARCD2

fi
exit
