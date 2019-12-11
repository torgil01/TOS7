#!/bin/bash
# extract freesurfer statistics from single folder
#



dataDir=freeSurfer
export SUBJECTS_DIR=$dataDir

# generate list of subjects and write to file
subjList=subj_list.txt
subj=$(find $dataDir -maxdepth 1 -mindepth 1 -type d -printf "%f\n ")
printf "%s\n" "${subj[@]}" > "$subjList"

# compute stats
asegstats2table --skip \
 		--subjectsfile=${subjList} \
 		--tablefile aseg_stats.csv \
 		--delimiter=comma \
 		--all-segs

aparcstats2table --hemi lh \
      		 --subjectsfile=${subjList} \
      		 --meas thickness \
      		 --parc aparc \
      		 --tablefile aparc_stats_lh.csv \
 		 --delimiter=comma \
                  --skip

aparcstats2table --hemi rh \
		 --subjectsfile=${subjList} \
     		 --meas thickness \
     		 --parc aparc \
     		 --tablefile aparc_stats_rh.csv \
		 --delimiter=comma \
                 --skip

    
