#!/bin/bash

studyDir=/home/torgil/Projects/TOS7/Convert/LastBatch/nii_fix/



files=$(find $studyDir -type f -name 't1_flair_3d.nii.gz')

for fi in ${files[@]}; do
    #fn=$(basename $fi .nii.gz)
    dn=$(dirname $fi)
    nn=$dn/t2_flair_3d.nii.gz
    echo "mv $fi -> $nn"
done


files=$(find $studyDir -type f -name 't1_flair_3d.json')

for fi in ${files[@]}; do
    dn=$(dirname $fi)
    nn=$dn/t2_flair_3d.json
    echo "mv $fi -> $nn"
done

