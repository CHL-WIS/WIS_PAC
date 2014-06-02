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
  WND HS DIR PHS PNR
$ (1) Forcing Fields
$  T
$ DPT CUR WND DT  WLV ICE IBG D50
$  F   F   T   F   F   F   F   F
$ (2) Standard mean wave Parameters
$  T
$ HS  LM  TZ  TE  TM  FP  DIR SPR DP
$  T   F   F   F   F   F   T   F   F
$ (3) Frequency-dependent parameters
$  F
$ EF TH1M STH1M TH1M STH1M WN
$  T  T  T  F  F  F
$ (4) Spectral Partition Parameters
$  T
$ PHS PTP PLP PTH PSP PWS WSF PNR
$  T   F   F   F   F   F   F   T 
$ (5) Atmosphere-waves layer
$  F
$ UST CHN CGE FAW TAW NWS WCC WCF WCH WCM
$  T   T   T   T   T   T   T   T   T   T
$ (6) Wave-Ocean layer
$  F
$ SXY TWO BHD FOC TUS USS P2S U3D P2L
$  T   T   T   T   T   T   T   F   F   F
$ (7) Wave-bottom layer
$  F
$ ABR UBR BED FBB TBB
$  T   T   T   T   T
$ (8) Spectrum parameters
$  F
$ MSS MSC
$  T   T
$ (9) Numerical diagnostics
$  F
$ DTD FC  CFX CFD CFK
$  T   T   T   T   T
$ (10) User defined (NOEXTR flags needed)
$  F
$ US1  US2
$ T    T
$
  3 0
  0 381 0 257 1 1
$
$ End of input file
EOF

$EXED/ww3_outf > ww3_outf1_basin_l1.out
wait
$SHEL/phs_conv.sh _sea
wait
cat > ww3_outf.inp << EOF
$ WAVEWATCH III Grid output post-processing
$ -----------------------------------------
  $startd1 $stcf 3600 1000
$
  N
  PHS 
$ (1) Forcing Fields
$  F
$ DPT CUR WND DT  WLV ICE IBG D50
$  F   T   T   T   T   F   F   F
$ (2) Standard mean wave Parameters
$  F
$ HS  LM  TZ  TE  TM  FP  DIR SPR DP
$  T   T   T   T   T   T   T   T   T
$ (3) Frequency-dependent parameters
$  F
$ EF TH1M STH1M TH1M STH1M WN
$  T  T  T  F  F  F
$ (4) Spectral Partition Parameters
$  T
$ PHS PTP PLP PTH PSP PWS WSF PNR
$  T   F   F   F   F   F   F   F 
$ (5) Atmosphere-waves layer
$  F
$ UST CHN CGE FAW TAW NWS WCC WCF WCH WCM
$  T   T   T   T   T   T   T   T   T   T
$ (6) Wave-Ocean layer
$  F
$ SXY TWO BHD FOC TUS USS P2S U3D P2L
$  T   T   T   T   T   T   T   F   F   F
$ (7) Wave-bottom layer
$  F
$ ABR UBR BED FBB TBB
$  T   T   T   T   T
$ (8) Spectrum parameters
$  F
$ MSS MSC
$  T   T
$ (9) Numerical diagnostics
$  F
$ DTD FC  CFX CFD CFK
$  T   T   T   T   T
$ (10) User defined (NOEXTR flags needed)
$  F
$ US1  US2
$ T    T
$
  3 1
  0 381 0 257 1 1
$
$ End of input file
EOF

$EXED/ww3_outf > ww3_outf2_basin_l1.out
wait
$SHEL/phs_conv.sh _sw1
wait
cat > ww3_outf.inp << EOF
$ WAVEWATCH III Grid output post-processing
$ -----------------------------------------
  $startd1 $stcf 3600 1000
$
  N
  PHS
$ (1) Forcing Fields
$  F
$ DPT CUR WND DT  WLV ICE IBG D50
$  F   T   T   T   T   F   F   F
$ (2) Standard mean wave Parameters
$  F
$ HS  LM  TZ  TE  TM  FP  DIR SPR DP
$  T   T   T   T   T   T   T   T   T
$ (3) Frequency-dependent parameters
$  F
$ EF TH1M STH1M TH1M STH1M WN
$  T  T  T  F  F  F
$ (4) Spectral Partition Parameters
$  T
$ PHS PTP PLP PTH PSP PWS WSF PNR
$  T   F   F   F   F   F   F   F 
$ (5) Atmosphere-waves layer
$  F
$ UST CHN CGE FAW TAW NWS WCC WCF WCH WCM
$  T   T   T   T   T   T   T   T   T   T
$ (6) Wave-Ocean layer
$  F
$ SXY TWO BHD FOC TUS USS P2S U3D P2L
$  T   T   T   T   T   T   T   F   F   F
$ (7) Wave-bottom layer
$  F
$ ABR UBR BED FBB TBB
$  T   T   T   T   T
$ (8) Spectrum parameters
$  F
$ MSS MSC
$  T   T
$ (9) Numerical diagnostics
$  F
$ DTD FC  CFX CFD CFK
$  T   T   T   T   T
$ (10) User defined (NOEXTR flags needed)
$  F
$ US1  US2
$ T    T
$
  3 2
  0 381 0 257 1 1
$
$ End of input file
EOF

$EXED/ww3_outf > ww3_outf3_basin_l1.out
wait
$SHEL/phs_conv.sh _sw2
wait
