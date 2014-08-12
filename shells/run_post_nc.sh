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

(   $SHEL/ww3_post_nc_point.sh  1 30 1 basin_l1 basin $STORM_NAME $BASE $BASIN $UNAME  > ww3_post1.out    ) &
(   $SHEL/ww3_post_nc_point.sh  31 60 2 basin_l1 basin $STORM_NAME $BASE $BASIN $UNAME  > ww3_post1.out    ) &
(   $SHEL/ww3_post_nc_point.sh  61 90 3 basin_l1 basin $STORM_NAME $BASE $BASIN $UNAME  > ww3_post1.out    ) &
(   $SHEL/ww3_post_nc_point.sh  91 120 4 basin_l1 basin $STORM_NAME $BASE $BASIN $UNAME  > ww3_post1.out    ) &
(   $SHEL/ww3_post_nc_point.sh  121 150 5 basin_l1 basin $STORM_NAME $BASE $BASIN $UNAME  > ww3_post1.out    ) &
(   $SHEL/ww3_post_nc_point.sh  151 180 6 basin_l1 basin $STORM_NAME $BASE $BASIN $UNAME  > ww3_post1.out    ) &
(   $SHEL/ww3_post_nc_point.sh  1 30 1 westc_l2 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post2.out    ) &
(   $SHEL/ww3_post_nc_point.sh  31 60 2 westc_l2 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post2.out    ) &
(   $SHEL/ww3_post_nc_point.sh  61 90 3 westc_l2 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post2.out    ) &
(   $SHEL/ww3_post_nc_point.sh  91 117 4 westc_l2 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post2.out    ) &
(   $SHEL/ww3_post_nc_point.sh  1 30 1 westc_l3 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post3.out    ) &
(   $SHEL/ww3_post_nc_point.sh  31 60 2 westc_l3 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post3.out    ) &
(   $SHEL/ww3_post_nc_point.sh  61 90 3 westc_l3 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post3.out    ) &
(   $SHEL/ww3_post_nc_point.sh  91 120 4 westc_l3 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post3.out    ) &
(   $SHEL/ww3_post_nc_point.sh  121 131 5 westc_l3 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post3.out    ) &
(   $SHEL/ww3_post_nc_point.sh  1 30 1 cali_l4  cali $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &
(   $SHEL/ww3_post_nc_point.sh  31 54 2 cali_l4  cali $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &
(   $SHEL/ww3_post_nc_point.sh  ALL ALL 1 hawaii_l2 hawaii $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &
(   $SHEL/ww3_post_nc_point.sh  ALL ALL 1 hawaii_l3 hawaii  $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &
#(   $SHEL/ww3_post_nc_field.sh  basin_l1 basin $STORM_NAME $BASE $BASIN $UNAME  > ww3_post1.out    ) &
#(   $SHEL/ww3_post_nc_field.sh  westc_l2 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post2.out    ) &
#(   $SHEL/ww3_post_nc_field.sh  westc_l3 westc $STORM_NAME $BASE $BASIN $UNAME > ww3_post3.out    ) &
#(   $SHEL/ww3_post_nc_field.sh  cali_l4  cali $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &
#(   $SHEL/ww3_post_nc_field.sh  hawaii_l2 hawaii $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &
#(   $SHEL/ww3_post_nc_field.sh  hawaii_l3 hawaii  $STORM_NAME $BASE $BASIN $UNAME > ww3_post4.out    ) &

wait

EOF
chmod 760 $WORKDIR/serial_post.sh

cat > $WORKDIR/tar_files.sh << EOF
#!/bin/bash

(  $SHEL/tar_points.sh $STORM_NAME $BASE basin_l1 ) &
(  $SHEL/tar_points.sh $STORM_NAME $BASE westc_l2 ) &
(  $SHEL/tar_points.sh $STORM_NAME $BASE westc_l3 ) &
(  $SHEL/tar_points.sh $STORM_NAME $BASE cali_l4 ) &
(  $SHEL/tar_points.sh $STORM_NAME $BASE hawaii_l2 ) &
(  $SHEL/tar_points.sh $STORM_NAME $BASE hawaii_l3 ) &
wait

EOF
chmod 760 $WORKDIR/tar_files.sh

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
export OMP_NUM_THREADS=32
#ccmrun  $WORKDIR/serial_post.sh -cpus=19 > serial_post.out 
#( ccmrun $SHEL/ww3_post_nc_point.sh 1 30 1 basin_l1 basin $STORM_NAME $BASE $BASIN $UNAME -cpus=1 > ww3_post1.out )
 ccmrun  $SHEL/ww3_post_nc_field.sh  basin_l1 basin $STORM_NAME $BASE $BASIN $UNAME  -cpus=32 > ww3_post1.out 
 ccmrun   $SHEL/ww3_post_nc_field.sh  westc_l2 westc $STORM_NAME $BASE $BASIN $UNAME -cpus=32 > ww3_post2.out  
 ccmrun   $SHEL/ww3_post_nc_field.sh  westc_l3 westc $STORM_NAME $BASE $BASIN $UNAME -cpus=32 > ww3_post3.out   
 ccmrun   $SHEL/ww3_post_nc_field.sh  cali_l4  cali $STORM_NAME $BASE $BASIN $UNAME -cpus=32 > ww3_post4.out 
 ccmrun   $SHEL/ww3_post_nc_field.sh  hawaii_l2 hawaii $STORM_NAME $BASE $BASIN $UNAME -cpus=32 > ww3_post4.out 
 ccmrun  $SHEL/ww3_post_nc_field.sh  hawaii_l3 hawaii  $STORM_NAME $BASE $BASIN $UNAME -cpus=32 > ww3_post4.out  
wait

#aprun -n 1 -d 6 $WORKDIR/tar_files.sh > tar_files.out
wait
#
# ----------------------------------------------------------------
# end submit script
# -------------------------------------------------------------
EOF

chmod 760 $WORKDIR/${STORM_NAME}_post.sh
qsub $WORKDIR/${STORM_NAME}_post.sh

