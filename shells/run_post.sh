#!/bin/bash

STORM_NAME=$1
RUN_NAME=$2
BASE=$3
BASIN=$4
UNAME=$5
EXED=$BASE/exe
SHEL=$BASE/shells
WORKDIR=$BASE/outdat/$STORM_NAME

cd $WORKDIR
cat > serial_post.sh << EOF
#!/bin/bash

cd $WORKDIR

(   $SHEL/ww3_post_mpi.sh  basin_l1 $STORM_NAME $BASE $BASIN $UNAME  > ww3_post1.out    ) &
(   $SHEL/ww3_post_mpi.sh  westc_l2 $STORM_NAME $BASE $BASIN $UNAME > ww3_post2.out    ) &
(   $SHEL/ww3_post_mpi.sh  westc_l3 $STORM_NAME $BASE $BASIN $UNAME > ww3_post3.out    ) &
(   $SHEL/ww3_post_mpi.sh  cali_l4  $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &

wait

EOF
chmod 760 $WORKDIR/serial_post.sh

cat > ${STORM_NAME}_post.sh << EOF
#!/bin/bash
#
#PBS -N ${RUN_NAME}_post
#PBS -q debug 
#PBS -A ERDCV03995SHS
#PBS -l select=1:ncpus=32:mpiprocs=32
#PBS -l walltime=01:00:00
#PBS -j oe
#PBS -o ${RUN_NAME}_post.oe
#PBS -m abe
#PBS -M thesser1@gmail.com
#PBS -l ccm=1
#PBS -l application=Other

#
#
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#      START OF THE BASIN SHELL SCRIPT FOR AUTOMATED FORECAST
#
#
# ---------------------------------
#
cd $WORKDIR

aprun -n 1 -d 4 $WORKDIR/serial_post.sh > serial_post.out
wait

#
# ----------------------------------------------------------------
# end submit script
# -------------------------------------------------------------
EOF

chmod 760 $WORKDIR/${STORM_NAME}_post.sh
qsub $WORKDIR/${STORM_NAME}_post.sh

