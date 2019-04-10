#!/bin/bash

# loop over folders

dataDir=TOS7_FS
subjList=subj_list.txt
export SUBJECTS_DIR=$dataDir
#subj=$(find $dataDir -maxdepth 1 -mindepth 1 -type d -printf "%f\n ")
#printf "%s\n" "${subj[@]}" > "$subjList"


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

    
