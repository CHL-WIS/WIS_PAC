#!/bin/bash

STORM_NAME=$1
RUN_NAME=$2
BASE=$3
BASIN=$4
EXED=$BASE/exe
SHEL=$BASE/shells
WORKDIR=$BASE/outdat/$STORM_NAME

cd $WORKDIR
cat > serial_points.sh << EOF
#!/bin/bash

cd $WORKDIR

   $SHEL/ww3_post_nc_point.sh  1 20 1 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  21 40 2 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  41 60 3 basin_l1 basin $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  61 80 4 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  81 100 5 basin_l1 basin $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  101 120 6 basin_l1 basin $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  121 140 7 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  141 160 8 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  161 180 9 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  181 200 10 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  201 220 11 basin_l1 basin $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  221 240 12 basin_l1 basin $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  241 260 13 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  261 280 14 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  281 300 15 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  301 320 16 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  321 340 17 basin_l1 basin $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  341 360 18 basin_l1 basin $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  361 380 19 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  381 400 20 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  401 420 21 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  421 440 22 basin_l1 basin $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  441 460 23 basin_l1 basin $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  461 480 24 basin_l1 basin $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  481 490 25 basin_l1 basin $STORM_NAME $BASE $BASIN  > ww3_post1.out     &


   $SHEL/ww3_post_nc_point.sh  1 25 1 westc_l2 westc $STORM_NAME $BASE $BASIN  > ww3_post2.out     &
   $SHEL/ww3_post_nc_point.sh  26 50 2 westc_l2 westc $STORM_NAME $BASE $BASIN  > ww3_post2.out     &
   $SHEL/ww3_post_nc_point.sh  51 75 3 westc_l2 westc $STORM_NAME $BASE $BASIN  > ww3_post2.out     &
   $SHEL/ww3_post_nc_point.sh  76 100 4 westc_l2 westc $STORM_NAME $BASE $BASIN  > ww3_post2.out     &
   $SHEL/ww3_post_nc_point.sh  101 125 5 westc_l2 westc $STORM_NAME $BASE $BASIN  > ww3_post2.out     &

   $SHEL/ww3_post_nc_point.sh  1 20 1 westc_l3 westc $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  21 40 2 westc_l3 westc $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  41 60 3 westc_l3 westc $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  61 80 4 westc_l3 westc $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  81 100 5 westc_l3 westc $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  101 120 6 westc_l3 westc $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  121 140 7 westc_l3 westc $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  141 160 8 westc_l3 westc $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  161 180 9 westc_l3 westc $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  181 200 10 westc_l3 westc $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  201 220 11 westc_l3 westc $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  221 240 12 westc_l3 westc $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  241 260 13 westc_l3 westc $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  261 280 14 westc_l3 westc $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  281 300 15 westc_l3 westc $STORM_NAME $BASE $BASIN   > ww3_post1.out     &

   $SHEL/ww3_post_nc_point.sh  1 25 1 cali_l4 cali $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  26 50 2 cali_l4 cali $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  51 75 3 cali_l4 cali $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  76 100 4 cali_l4 cali $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  101 125 5 cali_l4 cali $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  125 150 6 cali_l4 cali $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  151 175 7 cali_l4 cali $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  176 200 8 cali_l4 cali $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  201 225 9 cali_l4 cali $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  226 250 10 cali_l4 cali $STORM_NAME $BASE $BASIN   > ww3_post1.out     &

   $SHEL/ww3_post_nc_point.sh  ALL ALL 1 hawaii_l2 hawaii $STORM_NAME $BASE $BASIN  > ww3_post4.out     &

   $SHEL/ww3_post_nc_point.sh  1 25 1 hawaii_l3 hawaii $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  26 50 2 hawaii_l3 hawaii $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  51 75 3 hawaii_l3 hawaii $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  76 100 4 hawaii_l3 hawaii $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  101 125 5 hawaii_l3 hawaii $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  126 150 6 hawaii_l3 hawaii $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  151 175 7 hawaii_l3 hawaii $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  176 200 8 hawaii_l3 hawaii $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  161 180 9 hawaii_l3 hawaii $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
   $SHEL/ww3_post_nc_point.sh  181 200 10 hawaii_l3 hawaii $STORM_NAME $BASE $BASIN   > ww3_post1.out     &
wait

EOF
chmod 760 $WORKDIR/serial_points.sh

cd $WORKDIR
cat > serial_fields.sh << EOF
#!/bin/bash

cd $WORKDIR


   $SHEL/ww3_post_nc_field.sh  basin_l1 basin $STORM_NAME $BASE $BASIN 1  > ww3_post1.out    &
   $SHEL/ww3_post_nc_field.sh  basin_l1 basin $STORM_NAME $BASE $BASIN 2 > ww3_post2.out     &
   $SHEL/ww3_post_nc_field.sh  basin_l1 basin $STORM_NAME $BASE $BASIN 3 > ww3_post3.out     &
   $SHEL/ww3_post_nc_field.sh  basin_l1 basin $STORM_NAME $BASE $BASIN 4 > ww3_post2.out     &
   $SHEL/ww3_post_nc_field.sh  basin_l1 basin $STORM_NAME $BASE $BASIN 5 > ww3_post2.out     &

   $SHEL/ww3_post_nc_field.sh  westc_l2 westc $STORM_NAME $BASE $BASIN 1  > ww3_post1.out    &
   $SHEL/ww3_post_nc_field.sh  westc_l2 westc $STORM_NAME $BASE $BASIN 2 > ww3_post2.out     &
   $SHEL/ww3_post_nc_field.sh  westc_l2 westc $STORM_NAME $BASE $BASIN 3 > ww3_post3.out     &
   $SHEL/ww3_post_nc_field.sh  westc_l2 westc $STORM_NAME $BASE $BASIN 4 > ww3_post2.out     &
   $SHEL/ww3_post_nc_field.sh  westc_l2 westc $STORM_NAME $BASE $BASIN 5 > ww3_post2.out     &

   $SHEL/ww3_post_nc_field.sh  westc_l3 westc $STORM_NAME $BASE $BASIN 1  > ww3_post1.out    &
   $SHEL/ww3_post_nc_field.sh  westc_l3 westc $STORM_NAME $BASE $BASIN 2 > ww3_post2.out     &
   $SHEL/ww3_post_nc_field.sh  westc_l3 westc $STORM_NAME $BASE $BASIN 3 > ww3_post3.out     &
   $SHEL/ww3_post_nc_field.sh  westc_l3 westc $STORM_NAME $BASE $BASIN 4 > ww3_post2.out     &
   $SHEL/ww3_post_nc_field.sh  westc_l3 westc $STORM_NAME $BASE $BASIN 5 > ww3_post2.out     &

   $SHEL/ww3_post_nc_field.sh  cali_l4 cali $STORM_NAME $BASE $BASIN 1  > ww3_post1.out    &
   $SHEL/ww3_post_nc_field.sh  cali_l4 cali $STORM_NAME $BASE $BASIN 2 > ww3_post2.out     &
   $SHEL/ww3_post_nc_field.sh  cali_l4 cali $STORM_NAME $BASE $BASIN 3 > ww3_post3.out     &
   $SHEL/ww3_post_nc_field.sh  cali_l4 cali $STORM_NAME $BASE $BASIN 4 > ww3_post2.out     &
   $SHEL/ww3_post_nc_field.sh  cali_l4 cali $STORM_NAME $BASE $BASIN 5 > ww3_post2.out     &

   $SHEL/ww3_post_nc_field.sh  hawaii_l2 hawaii $STORM_NAME $BASE $BASIN 1  > ww3_post1.out    &
   $SHEL/ww3_post_nc_field.sh  hawaii_l2 hawaii $STORM_NAME $BASE $BASIN 2 > ww3_post2.out     &
   $SHEL/ww3_post_nc_field.sh  hawaii_l2 hawaii $STORM_NAME $BASE $BASIN 3 > ww3_post3.out     &
   $SHEL/ww3_post_nc_field.sh  hawaii_l2 hawaii $STORM_NAME $BASE $BASIN 4 > ww3_post2.out     &
   $SHEL/ww3_post_nc_field.sh  hawaii_l2 hawaii $STORM_NAME $BASE $BASIN 5 > ww3_post2.out     &

   $SHEL/ww3_post_nc_field.sh  hawaii_l3 hawaii $STORM_NAME $BASE $BASIN 1  > ww3_post1.out    &
   $SHEL/ww3_post_nc_field.sh  hawaii_l3 hawaii $STORM_NAME $BASE $BASIN 2 > ww3_post2.out     &
   $SHEL/ww3_post_nc_field.sh  hawaii_l3 hawaii $STORM_NAME $BASE $BASIN 3 > ww3_post3.out     &
   $SHEL/ww3_post_nc_field.sh  hawaii_l3 hawaii $STORM_NAME $BASE $BASIN 4 > ww3_post2.out     &
   $SHEL/ww3_post_nc_field.sh  hawaii_l3 hawaii $STORM_NAME $BASE $BASIN 5 > ww3_post2.out     &

wait

EOF
chmod 760 $WORKDIR/serial_fields.sh

cat > $WORKDIR/tar_points.sh << EOF
#!/bin/bash

  $SHEL/tar_points.sh $STORM_NAME $BASE basin_l1  &
  $SHEL/tar_points.sh $STORM_NAME $BASE westc_l2  &
  $SHEL/tar_points.sh $STORM_NAME $BASE westc_l3  &
  $SHEL/tar_points.sh $STORM_NAME $BASE cali_l4  &
  $SHEL/tar_points.sh $STORM_NAME $BASE hawaii_l2  &
  $SHEL/tar_points.sh $STORM_NAME $BASE hawaii_l3  &
wait

EOF
chmod 760 $WORKDIR/tar_points.sh

cat > $WORKDIR/netcdf_fields.sh << EOF
#!/bin/bash

   $SHEL/ww3_make_nc_field.sh  basin_l1 basin $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_make_nc_field.sh  westc_l2 westc $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_make_nc_field.sh  westc_l3 westc $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_make_nc_field.sh  cali_l4 cali $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_make_nc_field.sh  hawaii_l2 hawaii $STORM_NAME $BASE $BASIN  > ww3_post1.out     &
   $SHEL/ww3_make_nc_field.sh  hawaii_l3 hawaii $STORM_NAME $BASE $BASIN  > ww3_post1.out     &

wait

EOF
chmod 760 $WORKDIR/netcdf_fields.sh


cat > ${STORM_NAME}_points.sh << EOF
#!/bin/bash
#
#PBS -N ${RUN_NAME}_point
#PBS -q debug
#PBS -A ERDCV03995SHS
#PBS -l select=2:ncpus=32:mpiprocs=32
#PBS -l walltime=01:00:00
#PBS -j oe
#PBS -m abe
#PBS -M alan.cialone@usace.army.mil
#PBS -l ccm=1
#PBS -l application=Other

#
unmask 007
unmask
export MPICH_UNEX_BUFFER_SIZE=240M
export MPICH_ENV_DISPLAY=1
export MPICH_ABORT_ON_ERROR=1
export MPI_GROUP_MAX=32
#
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#      START OF THE BASIN SHELL SCRIPT FOR AUTOMATED FORECAST
#
#
# ---------------------------------
#
cd $WORKDIR
ccmrun $WORKDIR/serial_points.sh > serial_points.out

wait

ccmrun $WORKDIR/tar_points.sh > tar_points.out

wait
#
# ----------------------------------------------------------------
# end submit script
# -------------------------------------------------------------
EOF

chmod 760 $WORKDIR/${STORM_NAME}_points.sh
qsub $WORKDIR/${STORM_NAME}_points.sh

cat > ${STORM_NAME}_fields.sh << EOF
#!/bin/bash
#
#PBS -N ${RUN_NAME}_field
#PBS -q debug
#PBS -A ERDCV03995SHS
#PBS -l select=1:ncpus=32:mpiprocs=32
#PBS -l walltime=01:00:00
#PBS -j oe
#PBS -m abe
#PBS -M alan.cialone@usace.army.mil
#PBS -l ccm=1
#PBS -l application=Other

#
unmask 007
unmask
export MPICH_UNEX_BUFFER_SIZE=240M
export MPICH_ENV_DISPLAY=1
export MPICH_ABORT_ON_ERROR=1
export MPI_GROUP_MAX=32
#
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#      START OF THE BASIN SHELL SCRIPT FOR AUTOMATED FORECAST
#
#
# ---------------------------------
#
cd $WORKDIR
ccmrun $WORKDIR/serial_fields.sh > serial_fields.out
wait

ccmrun $WORKDIR/netcdf_fields.sh > netcdf_fields.out

wait
#
# ----------------------------------------------------------------
# end submit script
# -------------------------------------------------------------
EOF

chmod 760 $WORKDIR/${STORM_NAME}_fields.sh
qsub $WORKDIR/${STORM_NAME}_fields.sh

