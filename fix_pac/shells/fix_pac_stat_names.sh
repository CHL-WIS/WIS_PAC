#!/bin/bash

basin=$1
year=$2
mon=$3
BASE=$4

tfile=$year$mon"_WIS_PAC_WW3_OWI_ST4_"$basin"_wis_points.tgz"
fname="pac_"$basin"_fix_point_names.out"
rname="pac_"$basin"_remove_point_names.out"

fild=$BASE/files/
outd=$BASE/outdat/${year}-${mon}
if [ ! -d $outd ]
then 
 mkdir $outd
fi

cd $outd

newfdir='newfiles'
if [ ! -d $newfdir ]
then 
  mkdir $newfdir
fi

archive get -C /erdc1/cialonea/ERDCV03995SHS/PAC_2014/${year}${mon}_WIS_PAC_WW3_OWI_ST4/ $tfile

tar -xzvf $tfile
if [ -f $fild$fname ]
then
while read -r line
do 
  cc=( $line )
  name1=`echo ${cc[0]} `
  name2=`echo ${cc[1]} `
  echo "Change file name from $name1 to $name2"
  python $BASE/python_codes/adjust_station_name.py ST${name1}_${year}_${mon}.nc ${name2}
  mv ST${name1}_${year}_${mon}.nc $newfdir/ST${name2}_${year}_${mon}.nc

done < $fild$fname
else
  echo "No file names to change"
fi

if [ -f $fild$rname ]
then
while read -r line
do
 ff=ST${line}_${year}_${mon}.nc
 echo "Removing file name $ff"
 rm $ff
done < $fild$rname
else
  echo "No files to remove"
fi

if [ $basin == 'hawaii_l3' ] 
then 
  lname=$fild"wis_pac_hawaii_l3_5m_091614.out"
  while read -r line
  do 
    cc=( $line )
    lon=` echo ${cc[0]} `
    stat=` echo ${cc[2]} `
    echo "Fix lon for station $stat to $lon"
    ff=ST4${stat}_${year}_${mon}.nc
    if [ -f $ff ]
    then
       python $BASE/python_codes/fix_hawaii_lon.py $ff $lon
    fi
  done < $lname
fi

mv ST*.nc $newfdir
cd $newfdir
tar -czvf $tfile ST*.nc
