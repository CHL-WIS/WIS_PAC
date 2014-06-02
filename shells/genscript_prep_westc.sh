#!/bin/bash

WORKDIR=$1
EXED=$2

cd $WORKDIR
wname="'fort.12'"
cat > ww3_prep.inp << EOF
$ ---------------------------------------------------------------
$ WAVEWATCH III Field preprocessor input file
$ ---------------------------------------------------------------
   'WND' 'LL' T T
$
   220.00 250.0 121 30.0 50.00 81
  'NAME' 1 1 '(..T..)' '(..T..)'
  20 $wname
$
$ ---------------------------------------------------------------
$ end of input file
$ ---------------------------------------------------------------
EOF
#
# Run ww3_prep
$EXED/ww3_prep > ww3_prep_westc.out

