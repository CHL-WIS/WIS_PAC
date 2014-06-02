#!/bin/bash

endname=$1
ls -1 *.phs > fort.1
cat fort.1 | while read fname
do
fname2=$fname$endname
mv $fname $fname2
done
exit 0
