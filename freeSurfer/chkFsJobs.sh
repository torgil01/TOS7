#!/bin/bash

subjDir=$1

if [ -z "$subjDir" ]
then
    echo "you must supply Freesurfer SUBJECTS_DIR"
    exit 0
else   
    reconFiles=`find "$subjDir" -type f -name recon-all.log`
fi

for rec in ${reconFiles[@]}; do
    tmpName=`dirname $rec`
    tmpName2=`dirname $tmpName`
    id=`basename $tmpName2`
    status=`tail -n 1 "$rec"`
    echo $id " " $status
done

    
