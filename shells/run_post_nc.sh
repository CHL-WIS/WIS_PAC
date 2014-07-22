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

(   $SHEL/ww3_post_nc_point.sh  basin_l1 basin $STORM_NAME $BASE $BASIN $UNAME  > ww3_post1.out    ) &
(   $SHEL/ww3_post_nc_point.sh  westc_l2 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post2.out    ) &
(   $SHEL/ww3_post_nc_point.sh  westc_l3 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post3.out    ) &
(   $SHEL/ww3_post_nc_point.sh  cali_l4  cali $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &
(   $SHEL/ww3_post_nc_point.sh  hawaii_l2 hawaii $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &
(   $SHEL/ww3_post_nc_point.sh  hawaii_l3 hawaii  $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &
(   $SHEL/ww3_post_nc_field.sh  basin_l1 basin $STORM_NAME $BASE $BASIN $UNAME  > ww3_post1.out    ) &
(   $SHEL/ww3_post_nc_field.sh  westc_l2 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post2.out    ) &
(   $SHEL/ww3_post_nc_field.sh  westc_l3 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post3.out    ) &
(   $SHEL/ww3_post_nc_field.sh  cali_l4  cali $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &
(   $SHEL/ww3_post_nc_field.sh  hawaii_l2 hawaii $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &
(   $SHEL/ww3_post_nc_field.sh  hawaii_l3 hawaii  $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &

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
#PBS -M tyler.hesser@usace.army.mil
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

aprun -n 1 -d 12 $WORKDIR/serial_post.sh > serial_post.out
wait

#
# ----------------------------------------------------------------
# end submit script
# -------------------------------------------------------------
EOF

chmod 760 $WORKDIR/${STORM_NAME}_post.sh
qsub $WORKDIR/${STORM_NAME}_post.sh

