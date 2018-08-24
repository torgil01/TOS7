#!/bin/bash
# usage: 
# cpdir.sh dat.csv
#
SRC=/image_store/XNAT/
DEST=$HOME
# 
while IFS=, read col1 col2
do
	echo "cp -r  ${SRC}/${col2} ${DEST}/${col2}"
done < $1
