#!/bin/bash
# usage:
# recode.sh csv.file

# had to remove header from csv file.
# "xx","SHUFFLE_INDICES","IDS","NEW_IDS","TYPE"
csvFile=$1
sourceDir="/media/torgil/USB DISK 3/TOS7_NIFTI_LARS/"
destDir=/home/torgil/Projects/TOS7/test_retest/recode/
logfile=/home/torgil/Projects/TOS7/test_retest/recode.log
date > $logfile
while IFS=, read xx idx id new_id typ
do
    id=${id//[\"]/}
    new_id=${new_id//[\"]/}
    f1=$(find "$sourceDir" -type d -name $id)
    if [ -e "$f1" ]; then
	f2=${destDir}/$new_id
	cp -r "$f1"  "$f2" 
	echo "$f1 -> $f2" >> $logfile
	echo "$f1 -> $f2" 
    else
	echo "not found $f1" >> $logfile
	echo "not found $f1" 
	exit 2
    fi    
done < $csvFile




