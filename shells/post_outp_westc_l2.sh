#!/bin/bash
#
#
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

cat > ww3_outp.inp << EOF
$ --------------------------------------------------------------
$  WAVEWATCH III Point output post-processing
$ --------------------------------------------------------------
  $startd1 $stcf  3600 1000
$
$
   1
   2
   3
   4
   5
   6
$
  -1
$
$
  1
$
$
  3 1. 1. 31 F
$
$
$ ------------------------------------------------------------------------
$   End of input file
$ ------------------------------------------------------------------------
EOF
#
$EXED/ww3_outp > ww3_outp1_basin_l1.out
#
#
cat > ww3_outp.inp << EOF
$ --------------------------------------------------------------
$  WAVEWATCH III Point output post-processing
$ --------------------------------------------------------------
  $startd1 $stcf  3600 1000
$
$
   1
   2
   3
   4
   5
   6
$
  -1
$
$
  2 
$
$
  1 32
$
$
$ ------------------------------------------------------------------------
$   End of input file
$ ------------------------------------------------------------------------
EOF
#
$EXED/ww3_outp > ww3_outp2_basin_l1.out
#
#
cat > ww3_outp.inp << EOF
$ --------------------------------------------------------------
$  WAVEWATCH III Point output post-processing
$ --------------------------------------------------------------
  $startd1 $stcf  3600 1000
$
$
   1
   2
   3
   4
   5
   6
$
  -1
$
$
  2
$
$
  2 33
$
$
$ ------------------------------------------------------------------------
$   End of input file
$ ------------------------------------------------------------------------
EOF
#
$EXED/ww3_outp > ww3_outp3_basin_l1.out
#
#
cat > ww3_outp.inp << EOF
$ --------------------------------------------------------------
$  WAVEWATCH III Point output post-processing
$ --------------------------------------------------------------
  $startd1 $stcf  3600 1000
$
$
   1
   2
   3
   4
   5
   6
$
  -1
$
$
  2
$
$
  3 34
$
$
$ ------------------------------------------------------------------------
$   End of input file
$ ------------------------------------------------------------------------
EOF
#
$EXED/ww3_outp > ww3_outp4_basin_l1.out
