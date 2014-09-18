#!/bin/bash

STORM=$1
BASE=/lustre/work1/cialonea/WIS_PAC/outdat
BASED=$BASE/$STORM
ARC=/erdc1/cialonea/ERDCV03995SHS/PAC_2014
ARCD=$ARC/$STORM
ARCD2=gold.erdc.hpc.mil:$ARCD
if [ -d $BASED ] 
then
cd $BASED
tarname=$STORM"_model.tgz"
tar -czvf $tarname mod_def.* out_grd.* out_pnt.* nest.*

#if [ ! -d $ARC ] 
#then 
#archive mkdir -p $ARC
#rsh -l thesser1 gold.erdc.hpc.mil mkdir /erdc1/thesser1/ERDCV03995SHS/ATL/$ARC
#fi
echo $ARCD
#rsh -l thesser1 gold.erdc.hpc.mil mkdir $ARCD
archive mkdir -p $ARCD
#echo $ARCD2
#scp *.tgz $ARCD2
archive put -C $ARCD -s *.tgz
fi
exit
