#!/bin/bash

STORM_NAME=$1
RUN_NAME=$2
BASE=$3
EXED=$BASE/exe
SHEL=$BASE/shells
REST=$BASE/outdat/Restart
WORKDIR=$BASE/outdat/$STORM_NAME

cd $WORKDIR
cat > ${STORM_NAME}.sh << EOF
#!/bin/bash
#
#PBS -N $RUN_NAME
#PBS -q debug
#PBS -A ERDCV03995SHS
#PBS -l select=1:ncpus=32:mpiprocs=32
#PBS -l walltime=0:10:00
#PBS -j oe
#PBS -o $RUN_NAME.oe
#PBS -m abe
#PBS -M thesser1.usace@gmail.com

umask 007
#. /opt/modules/default/etc/modules.sh
#module swap PrgEnv-pgi PrgEnv-intel
#
#
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#      START OF THE BASIN SHELL SCRIPT FOR AUTOMATED FORECAST
#
#
# ---------------------------------
#
cd $WORKDIR

if [ ! -a $REST/restart.grd1 ]
 then
   cp $REST/restart.grd* $WORKDIR
   rm $REST/restart.grd*

fi
aprun -n 32 $EXED/ww3_multi > ww3_multi.out
wait

#mv restart.grd1 old-restart.grd1
#mv restart.grd2 old-restart.grd2
#$SHEL/make_restart.sh $STORM_NAME $BASE
#$SHEL/run_WW3_WIS.sh

#$SHEL/run_post.sh $STORM_NAME $RUN_NAME $BASE
#
# ----------------------------------------------------------------
# end submit script
# -------------------------------------------------------------
EOF

chmod 760 $WORKDIR/${STORM_NAME}.sh
#ssh $PBS_O_HOST qsub $WORKDIR/${STORM_NAME}.sh
#qsub $WORKDIR/${STORM_NAME}.sh
