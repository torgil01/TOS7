#!/bin/bash
# Preprocessing for wmh segmentation
# the script does:
#  1. generate white-matter mask and brainmask from FreeSurfer segmentations
#


cast_to_float () {
# convert input image to float 
    tmpFile=/tmp/img_$RANDOM.nii.gz
    fslmaths $1 -mul 1 $tmpFile -odt float
    rm $1
    mv "$tmpFile" "$1"        
    }

function chkFile () {
    if [ ! -e $1 ]
    then
	echo "Error file $1 is missing"
	exit 2
    fi
}


# change this 
# FsDir is where the freesurfer data lies
FsDir=/home/torgil/Projects/TOS7/FreeSurfer/SubjectsDir/
# MaskDir is where the masks are written 
MaskDir=/home/torgil/Projects/TOS7/FLAIR-seg/Mask-last-15

# presets 
asegName="aseg.mgz"
wmsegName="wmparc.mgz"

asegFiles=$(find "$FsDir" -type f -name ${asegName})
for aseg in ${asegFiles[@]}; do
    mriDir=$(dirname $aseg)
    idDir=$(dirname $mriDir)
    id=$(basename $idDir)

    if [ ! -d ${MaskDir}/${id} ]; then
	mkdir ${MaskDir}/${id}
    fi

    if [ -e ${MaskDir}/${id}/aseg.nii.gz ]; then
	if [ -e ${MaskDir}/${id}/wmparc.nii.gz ]; then
	    continue
	fi
    fi
    
    
    # original t1 and flair
    origT1mgz="${idDir}/mri/orig/001.mgz"
    origT1=${MaskDir}/${id}/t1.nii.gz
    chkFile $orgT1mgz
    mri_convert -i $origT1mgz -o $origT1 \
		--reslice_like $origT1mgz \
		-rt nearest 

    
    # convert aseg to nii
    asegNii=${MaskDir}/${id}/aseg.nii.gz
    mri_convert -i $aseg -o $asegNii \
		--reslice_like $origT1mgz \
		-rt nearest 
	
    
    # convert wmparc to nii
    # wmparc is in same dir as aparc
    wmsegFile="${mriDir}/${wmsegName}"
    wmsegNii=${MaskDir}/${id}/wmparc.nii.gz
    if [ ! -e $wmsegFile ]; then
	continue
    fi
        
    mri_convert -i $wmsegFile -o $wmsegNii \
		--reslice_like $origT1mgz \
		-rt nearest 
  

    # make brainmask
    # there is no brainmask in freesurfer, but we use the "brainmaks.mgz", which is
    # the skullstripped brain
    brain="${mriDir}/brainmask.mgz"
    brainNii=${MaskDir}/${id}/brain_tmp.nii.gz
    brainMask=${MaskDir}/${id}/t1_brainmask.nii.gz
    mri_convert -i $brain -o $brainNii \
		--reslice_like $origT1mgz \
		-rt nearest 
    fslmaths $brainNii -thr 5 -bin $brainMask -odt int
    
    # combine labels to make wm mask
    # LH-wm = 2
    # RH-wm = 41
    # wm-hyp = 77
    # lh_wmh = 78 -- empty but use anyway 
    # rh_wmh = 79 -- empty but use anyway
    # CC = 251 - 255
    # 
    
    wmMask=${MaskDir}/${id}/wm_mask.nii.gz
    labels=(2 41 77 78 79 251 252 253 254 255)
    tmpImg=/tmp/img_$RANDOM.nii.gz    
    i=0
    fslmaths ${origT1} -mul 0 ${wmMask}
    for lab in ${labels[@]}; do
	fslmaths ${asegNii} -uthr $lab -thr $lab -bin ${tmpImg}
	fslmaths ${tmpImg} -add ${wmMask} ${wmMask}
    done

    # cleanup
    rm -f $brainNii $tmpImg $origT1
    
done

