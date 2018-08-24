#!/bin/bash
# There is a rigid body transform between the
# flair images used as reference for manual segmentation and
# the original flair images. In such a case we can just replace the
# header to get the roi aigned to native space

refDir="/home/torgil/Projects/WMH-PET/misbah/ref_images/"
roiDir="/home/torgil/Projects/WMH-PET/misbah/misbah_whh-seg/seg-rev/"
fixRoiDir="/home/torgil/Projects/WMH-PET/misbah/misbah_whh-seg/roi_native/"
idList=$(find $refDir  -maxdepth 1 -mindepth 1 -type d)
echo $idList

# loop over IDs
for refDir in ${idList[@]};do
    id=$(basename $refDir)
    refFlair=${refDir}/T2_FLAIR_3D/t2_flair_3d.nii.gz
    refSF=$(fslorient -getsform $refFlair)
    refQF=$(fslorient -getqform $refFlair)
    # find the corresp. roi
    roi=${roiDir}/${id}_roi_fix.nii
    newRoi=${fixRoiDir}/${id}_roi.nii
    cp $roi $newRoi
    fslorient -setqform $refQF $newRoi
    fslorient -setsform $refSF $newRoi
done
