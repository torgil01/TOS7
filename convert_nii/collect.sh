#!/bin/bash

#TARGETS=(T1_3D_SAG.nii.gz)
#SUBDIR=T1_3D_SAG
#FNAME=t1_3d_sag.nii.gz

#TARGETS=(T2_FLAIR_3D.nii.gz)
#SUBDIR=T2_FLAIR_3D
#FNAME=t2_flair_3d.nii.gz

#TARGETS=(3D_TOF.nii.gz)
#SUBDIR=3D_TOF
#FNAME=3d_tof.nii.gz

TARGETS=(SWI_TRA.nii.gz)
SUBDIR=SWI_Images
FNAME=swi_images.nii.gz




STUDY_DIR=/home/torgil/Projects/TOS7/Convert/LastBatch/nii_extra/
destDir=/home/torgil/Projects/TOS7/Convert/LastBatch/nii_extra_fixed/

# loop over study dir and find target
subjDirs=(`find $STUDY_DIR -maxdepth 1 -mindepth 1 -type d`)
for d in ${subjDirs[@]}; do
    id=`basename "$d"`	
    for t in ${TARGETS[@]}; do
	echo "search $t in $d"
	target=$(find "$d" -type f -name "$t")
	echo $target
	kk=0
	for tt in ${target[@]}; do
	    if [[ -n $tt ]]; then
		echo $tt
		fn=`basename $tt .nii.gz`
		dn=$(dirname $tt)
		json_from=${dn}/${fn}.json
		json_to=$(basename $FNAME .nii.gz)

		# hack for swi
		it=$(grep SliceThickness "$json_from")
		it=${it#*:}
		if  [ "$it" != " 1.6," ]; then
		    #echo "$it"
		    continue
		fi
	    
	    
	    if [ ! -e ${destDir}/${id} ]; then
	       mkdir ${destDir}/${id}
	    fi
	    if [ ! -e ${destDir}/${id}/${SUBDIR} ]; then	       
		mkdir ${destDir}/${id}/${SUBDIR}
		toDir=${destDir}/${id}/${SUBDIR}
	    else
		mkdir ${destDir}/${id}/${SUBDIR}
		toDir=${destDir}/${id}/${SUBDIR}
	    fi
       	    # actual copy
	    if [ ! -f ${toDir}/${FNAME} ]; then	       
		cp $tt ${toDir}/${FNAME}
		 cp $json_from ${toDir}/${json_to}.json
	    fi	    
	    # found target exiting current loop
	    #break
	fi
	kk=$((kk +1))
	done
	
    done
done

