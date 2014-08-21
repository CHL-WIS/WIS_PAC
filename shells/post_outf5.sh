#!/bin/bash

STORM_NAME=$1
BASE=$2
WORKD=$3
level=$4
#WORKD=$BASE/outdat/$STORM_NAME

EXED=$BASE/exe
SHEL=$BASE/shells
#WORKD=$BASE/outdat/$STORM_NAME

cd $WORKD

startd1=`awk '{printf "%s", $1} ' ${STORM_NAME}.datesin `
startd2=`awk '{printf "%s", $2} ' ${STORM_NAME}.datesin `

#nlon=`awk '{printf "%i", $1} ' ${STORM_NAME}.coords `
#nlat=`awk '{printf "%i", $2} ' ${STORM_NAME}.coords `

stname=`echo $startd1 | cut -c1-6 `
st1=`echo $startd2 | cut -c1-2 `
ste=`echo $startd2 | cut -c3-6 `
st2=`echo $((st1+1)) `
if [ $st2 -lt "10" ]
  then
  stc="0"$st2
else
  stc=$st2
fi
stcf=$stc$ste
cat > ww3_outf.inp << EOF
$ WAVEWATCH III Grid output post-processing
$ -----------------------------------------
  $startd1 $stcf 3600 1000
$
  N
  PHS PTP PDIR
$
  3 2
 0 1000 0 1000 1 1
$  0 381 0 257 1 1
$
$ End of input file
EOF

$EXED/ww3_outf > ww3_outf3_$level.out
wait
$SHEL/phs_conv.sh _sw2
wait
