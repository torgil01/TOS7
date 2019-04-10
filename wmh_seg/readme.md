# Preprocessing for UNET WMH segmentation
Prior to UNET the T1 and FLAIR images are coregistered and cropped. After UNET is run the WMH segmentation is corrected with a white matter mask derived from FreeSurfer.


**preproc_unet_1.sh**
This script read the FreeSurfer `SUBJECTS_DIR` and for each subject writes several segmentation files in nii format to a separate directory.

The following files are made
 * `aseg.nii.gz`  : FreeSurfer aseg in native T1-space
 * `t1_brainmask.nii.gz` : a rough brainmask (from brainmask.mgz) in native T1-space
 * `wm_mask.nii.gz` : white matter mask drived from aseg, by merging aseg labels.
 * `wmparc.nii.gz` :_white matter parcellation in native T1-space

**preproc_unet_2.sh**
This script realign T1 -> FLAIR, followed by a rigid-body transfrom to the MNI template to standardize the image orientation. The white matter mask is also coregistered to the FLAIR image.

