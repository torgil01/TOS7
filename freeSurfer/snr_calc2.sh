#!/bin/bash

# Calculate SNR and CNR from FreeSurfer data
# uses the "mri_cnr" and "wm-anat-snr" scrips
#
# Data is stored in subfolders under the main analysis directory
#

dataDir=$1
snr_out=/home/torgil/Projects/TOS7/FreeSurfer/scripts/snr_log_all2.txt
cnr_out=/home/torgil/Projects/TOS7/FreeSurfer/scripts/cnr_log_all2.txt

export SUBJECTS_DIR=$1    

subjects=$(find "$dataDir" -maxdepth 1 -mindepth 1 -type d)



# snr calc
for thisSubjectDir in ${subjects[@]}; do
    id=$(basename $thisSubjectDir)
    tempdir=/tmp/tmp_$RANDOM
    mkdir $tempdir
    wm-anat-snr --s $id --tmp $tempdir
    if [ -e $tempdir ]; then
	rm -rf $tempdir
    fi	
done
cat $SUBJECTS_DIR/*/stats/wmsnr.e3.dat | sort -k 2 -n >> $snr_out


# cnr calc
# header
echo "id lh_gray_white_cnr lh_gray_cfs_cnr lh_white lh_gray lh_csf lh_white_std lh_gray_std lh_csf_std \
rh_gray_white_cnr rh_gray_cfs_cnr rh_white rh_gray rh_csf rh_white_std rh_gray_std rh_csf_std" > $cnr_out

for thisSubjectDir in ${subjects[@]}; do
    id=$(basename $thisSubjectDir)
    tmpFile=/tmp/fs_cnr_$RANDOM
    mri_cnr -L $tmpFile ${thisSubjectDir}/surf ${thisSubjectDir}/mri/T1.mgz
    # in tmpfile 1st line is lh 2nd line rh
    # labels
    # gray/white cnr | gray/csf cnr | white | gray | csf | std white | std gray | std csf 
    i=0
    while IFS='' read -r line
    do
	lines[$i]=${line}
	i=$((i+1))
    done < $tmpFile
    echo $id ${lines[0]} ${lines[1]} >> $cnr_out
    rm $tmpFile
done

    

