#!/bin/bash

cd /outdat/200711_WIS_PAC_WW3_OWI_ST4

(   /shells/ww3_post_mpi.sh  basin_l1 basin_level1 200711_WIS_PAC_WW3_OWI_ST4   > ww3_post1.out    ) &
(   /shells/ww3_post_mpi.sh  westc_l2 westc_level2 200711_WIS_PAC_WW3_OWI_ST4   > ww3_post2.out    ) &
(   /shells/ww3_post_mpi.sh  westc_l3 westc_level3 200711_WIS_PAC_WW3_OWI_ST4   > ww3_post3.out    ) &
(   /shells/ww3_post_mpi.sh  cali_l4 cali_level4 200711_WIS_PAC_WW3_OWI_ST4   > ww3_post4.out    ) &

wait

