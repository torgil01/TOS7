#!/bin/bash

tof=$1
TEMPLATE=$2
ROI=$3

tofdir=$(dirname $tof)
matFile=${tofdir}/mni_to_native.mat
tof_1mm=${tofdir}/tof_1mm.nii.gz
native_roi=${tofdir}/roi.nii.gz
cropped_tof=${tofdir}/tof_crop.nii.gz

# calculate  MNI -> TOF transform
# Resample - speed up flirt
ResampleImageBySpacing 3 $tof $tof_1mm 1 1 1 0 0 0 
# Calc MNI -> tof transform on 1mm images
flirt -in $TEMPLATE -ref $tof_1mm -omat $matFile -cost mutualinfo
# apply transform to ROI
flirt -in $ROI -ref $tof -out $native_roi -init $matFile -applyxfm -interp nearestneighbour
# multiply tof with mask
fslmaths $tof -mul $native_roi $cropped_tof 
# remove interpolated tof
rm $tof_1mm
