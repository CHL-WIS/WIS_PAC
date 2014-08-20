#!/bin/bash

STORM_NAME=$1
RUN_NAME=$2
BASE=$3
BASIN=$4
UNAME=$5
EXED=$BASE/exe
SHEL=$BASE/shells
REST=$BASE/outdat/Restart
WORKDIR=$BASE/outdat/$STORM_NAME

cd $WORKDIR
cat > ${STORM_NAME}.sh << EOF
#!/bin/bash
#
#PBS -N $RUN_NAME
#PBS -q standard
#PBS -A ERDCV03995SHS
#PBS -l select=4:ncpus=32:mpiprocs=32
#PBS -l walltime=5:30:00
#PBS -j oe
#PBS -o $RUN_NAME.oe
#PBS -m abe
#PBS -M alan.cialone@usace.army.mil

umask 007
#
#
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#      START OF THE BASIN SHELL SCRIPT FOR AUTOMATED FORECAST
#
#
# ---------------------------------
#
cd $WORKDIR

if [ ! -a $REST/restart.basin_l1 ]
 then
   cp $REST/restart.* $WORKDIR
   rm $REST/restart.*

fi
aprun -n 128 $EXED/ww3_multi > ww3_multi.out
wait

mv restart.basin_l1 old-restart.basin_l1
mv restart.westc_l2 old-restart.westc_l2
mv restart.westc_l3 old-restart.westc_l3
mv restart.cali_l4 old-restart.cali_l4
mv restart.hawaii_l2 old-restart.hawaii_l2
mv restart.hawaii_l3 old-restart.hawaii_l3
$SHEL/make_restart.sh $STORM_NAME $BASE
$SHEL/run_WW3_WIS.sh

$SHEL/run_post_nc.sh $STORM_NAME $RUN_NAME $BASE $BASIN $UNAME
#
# ----------------------------------------------------------------
# end submit script
# -------------------------------------------------------------
EOF

chmod 760 $WORKDIR/${STORM_NAME}.sh
#ssh $PBS_O_HOST qsub $WORKDIR/${STORM_NAME}.sh
qsub $WORKDIR/${STORM_NAME}.sh
