#!/bin/bash

STORM_NAME=$1
BASE=$2
REST=$BASE/outdat/Restart
WORKDIR=$BASE/outdat/$STORM_NAME
tarname=$STORM_NAME"-restart.tgz"

cd $WORKDIR
restname=`ls -tr restart* | tail -6 ` 
cp $restname $REST

tarname=$STORM_NAME-rest.tgz
tar -czf $tarname $restname old-restart.* nest.*

mv $REST/*.basin_l1 $REST/restart.basin_l1
mv $REST/*.westc_l2 $REST/restart.westc_l2
mv $REST/*.westc_l3 $REST/restart.westc_l3
mv $REST/*.cali_l4 $REST/restart.cali_l4
mv $REST/*.hawaii_l2 $REST/restart.hawaii_l2
mv $REST/*.hawaii_l3 $REST/restart.hawaii_l3
