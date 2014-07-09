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

cat > ww3_ounp.inp << EOF
$ --------------------------------------------------------------
$  WAVEWATCH III Point output post-processing
$ --------------------------------------------------------------
  $startd1 $stcf  3600 1000
$
  -1
$
$
  ww3_spec.
  6
$
  4
$
 T 1000
$
 1
 0
$
  3 1 1
$
$
$ ------------------------------------------------------------------------
$   End of input file
$ ------------------------------------------------------------------------
EOF
#
$EXED/ww3_ounp > ww3_ounp1_basin_l1.out
#
#
cat > ww3_ounp.inp << EOF
$ --------------------------------------------------------------
$  WAVEWATCH III Point output post-processing
$ --------------------------------------------------------------
  $startd1 $stcf  3600 1000
$
$
$
  -1
$
$
  ww3_ust.
  6 
$
  4
$
 T 1000
 2
 0
$ 
 3
$
$ ------------------------------------------------------------------------
$   End of input file
$ ------------------------------------------------------------------------
EOF
#
$EXED/ww3_ounp > ww3_ounp2_basin_l1.out
#
#
cat > ww3_ounp.inp << EOF
$ --------------------------------------------------------------
$  WAVEWATCH III Point output post-processing
$ --------------------------------------------------------------
  $startd1 $stcf  3600 1000
$
$
$
  -1
$
$
  ww3_u10.
  6 
$
  4
$
 T 1000
 2
 0
$ 
 4
$
$
$ ------------------------------------------------------------------------
$   End of input file
$ ------------------------------------------------------------------------
EOF
#
$EXED/ww3_ounp > ww3_ounp3_basin_l1.out
#
#
cat > ww3_ounp.inp << EOF
$ --------------------------------------------------------------
$  WAVEWATCH III Point output post-processing
$ --------------------------------------------------------------
  $startd1 $stcf  3600 1000
$
$
$
  -1
$
$
  ww3_dep.
  6 
$
  4
$
 T 1000
 2
 0
$ 
 1
$
$ ------------------------------------------------------------------------
$   End of input file
$ ------------------------------------------------------------------------
EOF
#
$EXED/ww3_ounp > ww3_ounp4_basin_l1.out


