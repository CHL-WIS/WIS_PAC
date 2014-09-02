#!/bin/bash

INPF=$1
WORKDIR=$2
EXED=$3

WDIR=$INPF/grids/cali

cd $WDIR
for file in ./*cali*.grd ; do
  gridf=$file
done
for file in ./*cali*.obstr ; do
  obstf=$file
done
for file in ./*cali*.mask ; do
  maskf=$file
done
cp $WDIR/$gridf $WORKDIR/.
cp $WDIR/$obstf $WORKDIR/.
cp $WDIR/$maskf $WORKDIR/.
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
  'Pacific cali 90 second grid   '
$
   1.1  0.035  29  72  0.5
$
   F T T T F T
$
   275. 88. 136. 15.
$
$  &SIN4 BETAMAX = 1.33 /
  &MISC FLAGTR = 2 /
END OF NAMELISTS
$
$ In this case, the mask is provided separate from the bottom grid,
$ the obstructions are taken from both neighbouring cells.
$
    'RECT' T 'NONE'
    156     96
     90.    90.    3600.
    239.1875  32.1875     1.
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
$EXED/ww3_grid > ww3_grid_cali_l4.out

