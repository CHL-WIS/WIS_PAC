#!/bin/bash

STORM_NAME=$1
BASE=$2
WORKD=$3
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
  $startd1 $stcf  3600 1000
$
  N
  WND HS FP DIR SPR PHS PTP PDIR PNR
$
  3 0
  0 53 0 45 1 1
$
$ End of input file
EOF

$EXED/ww3_outf > ww3_outf1_hawaii_l2.out
wait
$SHEL/phs_conv.sh _sea
wait

cat > ww3_outf.inp << EOF
$ WAVEWATCH III Grid output post-processing
$ -----------------------------------------
  $startd1 $stcf 3600 1000
$
  N
  PHS PTP PDIR
$
  3 1
  0 53 0 45 1 1
$
$ End of input file
EOF

$EXED/ww3_outf > ww3_outf2_hawaii_l2.out
wait
$SHEL/phs_conv.sh _sw1
wait

cat > ww3_outf.inp << EOF
$ WAVEWATCH III Grid output post-processing
$ -----------------------------------------
  $startd1 $stcf 3600 1000
$
  N
  PHS PTP PDIR
$
  3 2
  0 53 0 45 1 1
$
$ End of input file
EOF

$EXED/ww3_outf > ww3_outf3_hawaii_l2.out
wait
$SHEL/phs_conv.sh _sw2
wait
