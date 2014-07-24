#!/bin/bash
#
#
STORM_NAME=$1
BASE=$2
WORKD=$3
lev=$4
sta=$5
sto=$6
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
if [ $sta == 'ALL' ]
 then
  inp='$'
else
  inp=$(seq $sta $sto)
fi
cat > ww3_ounp.inp << EOF
$ --------------------------------------------------------------
$  WAVEWATCH III Point output post-processing
$ --------------------------------------------------------------
  $startd1 $stcf  3600 1000
$
$inp
  -1
$
$
  ww3.
  6
$
  4
$
 F 1000
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
$EXED/ww3_ounp > ww3_ounp1_$lev.out
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
$inp
  -1
$
$
  ww3_ust.
  6 
$
  4
$
 F 1000
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
$EXED/ww3_ounp > ww3_ounp2_$lev.out
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
$inp
  -1
$
$
  ww3_u10.
  6 
$
  4
$
 F 1000
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
$EXED/ww3_ounp > ww3_ounp3_$lev.out
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
$inp
  -1
$
$
  ww3_dep.
  6 
$
  4
$
 F 1000
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
$EXED/ww3_ounp > ww3_ounp4_$lev.out


