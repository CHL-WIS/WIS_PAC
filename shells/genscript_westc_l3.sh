#!/bin/bash

INPF=$1
WORKDIR=$2
EXED=$3

cd $INPF
ls -1 *westc_l3* > grid.1
exec 3<&0
exec 0<"grid.1"
read gridf
read maskf
read obstf
cp $INPF/$gridf $WORKDIR/.
cp $INPF/$obstf $WORKDIR/.
cp $INPF/$maskf $WORKDIR/.
gf="'"$gridf"'"
of="'"$obstf"'"
mf="'"$maskf"'"
cd $WORKDIR
#
cat > ww3_grid.inp << EOF
$ -------------------------------------------------------------------- $
$ WAVEWATCH III Grid preprocessor input file                           $
$ -------------------------------------------------------------------- $
$
  'Pacific westc 5 minute grid   '
$
   1.1  0.035  29  72  0.5
$
   F T T T F T
$
   550. 230. 275. 15.
$
  &SIN4 BETAMAX = 1.33 /
  &MISC FLAGTR = 2 /
END OF NAMELISTS
$
$ In this case, the mask is provided separate from the bottom grid,
$ the obstructions are taken from both neighbouring cells.
$
    'RECT' T 'NONE'
    181    241
      5.     5.     60.
    230.0   30.0     1.
     -0.1    2.5   20   0.001  1 1 '(...)' 'NAME' $gf
                   21   0.01   1 1 '(...)' 'NAME' $of
                   22          1 1 '(...)' 'NAME' $mf
$
     0.    0.    0.    0.       0
$
$ -------------------------------------------------------------------- $
$ End of input file                                                    $
$ -------------------------------------------------------------------- $
EOF
#
#  Run ww3_grid
$EXED/ww3_grid > ww3_grid_westc_l3.out

