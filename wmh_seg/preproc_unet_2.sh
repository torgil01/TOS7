#!/bin/bash
# Preprocessing for wmh segmentation
# the script does 
#  2. bias-field correct t1 and flair + realign t1 -> flair 

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

function chkDir () {
    if [ ! -d $1 ]
    then
	echo "Error dir $1 is missing"
	exit 2
    fi
}


function mkPng () {
    anat=$1
    overlay=$2
    pngOut=$3
    
    # set up tmpdir
    tmpdir=`mktemp -d`

    # reorient
    reAnat=${tmpdir}/anat.nii.gz
    cAnat=${tmpdir}/canat.nii.gz
    reOverlay=${tmpdir}/overlay.nii.gz
    cOverlay=${tmpdir}/coverlay.nii.gz
    fslreorient2std $anat $reAnat
    fslreorient2std $overlay $reOverlay

    # crop
    fslroi $reAnat $cAnat -1 -1  -1 -1 13 155
    fslroi $reOverlay $cOverlay -1 -1  -1 -1 13 155

    # mk color overlays
    rendered=${tmpdir}/rendered.nii.gz
    overlay 0 1  $cAnat -a  $cOverlay 0.95 1 $rendered

    # mk slices
    slicer $rendered -L -n -S 4 1600 $pngOut
 
    # cleanup
    rm -r $tmpdir
}


# change this 
MaskDir=/home/torgil/Projects/TOS7/FLAIR-seg/Mask_dir/
imDir=/home/torgil/Projects/TOS7/FLAIR-seg/Test/

# presets 
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=12
searchcost=mutualinfo
cost=mutualinfo
mniTemplate=${FSL_DIR}/data/standard/MNI152_T1_1mm_brain.nii.gz 
mniTemplateBrainmask=${FSL_DIR}/data/standard/MNI152_T1_1mm_brain_mask.nii.gz

# dbug
n4_correct=true
watershed=true
writeLog=true


maskDirs=$(find $MaskDir -maxdepth 1 -mindepth 1 -type d)
for mdir in ${maskDirs[@]}; do    
    id=$(basename $mdir)
    echo $id    
    
    # original t1 and flair
    subjDir=${imDir}/${id}
    t1Dir=${subjDir}/T1_3D_SAG
    flDir=${subjDir}/T2_FLAIR_3D/
    origT1=${t1Dir}/t1_3d_sag.nii.gz
    flair=${flDir}/t2_flair_3d.nii.gz
    
    chkDir $subjDir
    chkDir $t1Dir
    chkDir $flDir
    chkFile $origT1
    chkFile $flair

    
    if [ "$writeLog" = true ]; then
	logFile=${subjDir}/unet_preproc.log
	startTime=$(date)
	echo "#ID = $id" >> $logFile	
	echo "#start $startTime" >> $logFile	
    fi

    # copy files from mask dir to subj dir
    cp ${mdir}/wm_mask.nii.gz ${t1Dir}/.
    cp ${mdir}/t1_brainmask.nii.gz ${t1Dir}/.
    cp ${mdir}/wmparc.nii.gz ${t1Dir}/.
    cp ${mdir}/aseg.nii.gz ${t1Dir}/.

    brainMask=${t1Dir}/t1_brainmask.nii.gz
    wmMask=${t1Dir}/wm_mask.nii.gz

    
    # N4 bias field corr on t1
    # TODO: check whether it is better to correct on the skull stripped image
    # t1N4=${imDir}/${id}/T1_3D_SAG/t1_N4.nii.gz
    # if [ "$n4_correct" = true ]; then
    # 	N4BiasFieldCorrection -d 3 -i $origT1 -o $t1N4
    # 	cast_to_float $t1N4
    # fi

    
    # skull strip the bias field corrected t1-image
    t1Brain=${t1Dir}/t1_brain.nii.gz
    fslmaths $origT1 -mul $brainMask $t1Brain

    # N4 on flair
    #
    # flairN4=${imDir}/${id}/T2_FLAIR_3D/flair_n4.nii.gz
    # if [ "$n4_correct" = true ]; then
    # 	N4BiasFieldCorrection -d 3 -i $flair -o $flairN4
    # 	cast_to_float $flairN4
    # fi
    

    # coreg T1 -> FLAIR
    target=$flair
    moving=$t1Brain
    t1_to_fl=${t1Dir}/t1_to_flair
    warpName=$t1_to_fl
    # A . reg t1_brain -> flair_brain (transform only)
    echo "ants: compute transform  t1 -> flair; write to $mat "    
    antsRegistration --verbose 1\
    		 --dimensionality 3\
    		 --float 0\
    		 --output [${warpName}] \
    		 --interpolation Linear \
    		 --use-histogram-matching 0 \
    		 --winsorize-image-intensities [0.005,0.995]\
    		 --initial-moving-transform [${target},${moving},1]\
    		 --transform Rigid[0.1]\
    		 --metric MI[${target},${moving},1,32,Regular,0.25]\
    		 --convergence [1000x500x250x10,1e-6,10]\
    		 --shrink-factors 8x4x2x1\
    		 --smoothing-sigmas 3x2x1x0vox

    # write coreg diagnostics to logfile
    if [ "$writeLog" = true ]; then
	imSimFile=${subjDir}/sim_flair_t1.log
	MeasureImageSimilarity 3 2 $flair $t1Brain $imSimFile
	echo "#t1_to_flair" >> $logFile
	cat $imSimFile >> $logFile
	rm $imSimFile
    fi


    # apply transform 
    t1Tmp=${t1Dir}/t1_to_fl.nii.gz
    inFile=$t1Brain
    outFile=$t1Tmp
    antsApplyTransforms -d 3 -i ${inFile} \
     			    -r ${flair} \
     			    -o ${outFile} \
       			    -t ${warpName}0GenericAffine.mat -v 1



    
    # compute initial rigid body transf to mni 
    fl_to_mni=${t1Dir}/fl_to_mni
    warpName=$fl_to_mni
    target=$mniTemplate
    moving=$t1Tmp
    echo "ants: compute flair-> MNI; writing transform to $mat_mni"
    antsRegistration --verbose 1\
    		 --dimensionality 3\
    		 --float 0\
    		 --output [${warpName}] \
    		 --interpolation Linear \
    		 --use-histogram-matching 0 \
    		 --winsorize-image-intensities [0.005,0.995]\
    		 --initial-moving-transform [${target},${moving},1]\
    		 --transform Rigid[0.1]\
    		 --metric MI[${target},${moving},1,32,Regular,0.25]\
    		 --convergence [1000x500x250x10,1e-6,10]\
    		 --shrink-factors 8x4x2x1\
    		 --smoothing-sigmas 3x2x1x0vox


    
    # write flair-nii -> mni
    flair_mni=${flDir}/flair_mni.nii.gz
    echo "ants: write flair-> MNI; $flair_mni "
    inFile=$flair
    outFile=$flair_mni
    ref=$mniTemplate
    warpName=$fl_to_mni
    antsApplyTransforms -d 3 -i ${inFile} \
     			    -r ${ref} \
     			    -o ${outFile} \
       			    -t ${warpName}0GenericAffine.mat \
			    -n BSpline \
			    -v 1

    cast_to_float $flair_mni
   
    
    # write wm-mask to flair-mni-space
    flairWmMask=${flDir}/wm_mask.nii.gz
    echo "ants: transform  wmMask -> flair_MNI;  $flairWmMask "
    inFile=$wmMask 
    outFile=$flairWmMask
    ref=$mniTemplate
    antsApplyTransforms -d 3 -i ${inFile} \
     			    -r ${ref} \
     			    -o ${outFile} \
       			    -t ${fl_to_mni}0GenericAffine.mat \
			    -t ${t1_to_fl}0GenericAffine.mat \
			    -n NearestNeighbor \
			    -v 1

    # write brainmsk to flair-mni-space
    mniBrainMask=${flDir}/brain_mask.nii.gz
    echo "ants: transform  wmMask -> flair_MNI;  $flairWmMask "
    inFile=$brainMask
    outFile=$mniBrainMask
    ref=$mniTemplate
    antsApplyTransforms -d 3 -i ${inFile} \
     			    -r ${ref} \
     			    -o ${outFile} \
       			    -t ${fl_to_mni}0GenericAffine.mat \
			    -t ${t1_to_fl}0GenericAffine.mat \
			    -n NearestNeighbor \
			    -v 1
    
    # Compute dice for brainamsk 
    if [ "$writeLog" = true ]; then
	echo "#dice_brainmask" >> $logFile
	diceLog=${subjDir}/dice_mniBrainmask
	ImageMath 3  $diceLog DiceAndMinDistSum $mniTemplateBrainmask $mniBrainMask >> $logFile
	cat $diceLog >> $logFile
	cat ${diceLog}.csv >> $logFile
	rmFile1=${diceLog}dice.nii.gz
	rmFile2=${diceLog}mds.nii.gz
	rmFile3=${diceLog}
	rm $rmFile1 $rmFile2 $rmFile3  ${diceLog}.csv
    fi

    
    # write t1 to flair-mni space
    t1_flair_mni=${t1Dir}/t1_mni.nii.gz
    echo "flirt: transform  t1 -> flair_MNI;  $t1_flair_mni "
    inFile=$origT1
    outFile=$t1_flair_mni
    ref=$mniTemplate
    antsApplyTransforms -d 3 -i ${inFile} \
     			    -r ${ref} \
     			    -o ${outFile} \
       			    -t ${fl_to_mni}0GenericAffine.mat \
			    -t ${t1_to_fl}0GenericAffine.mat \
			    -n BSpline \
			    -v 1

    cast_to_float $t1_flair_mni


    # write coreg diagnostics to logfile
    if [ $writeLog = true ]; then
	imSimFile=${subjDir}/sim_t1_to_mni.log
	MeasureImageSimilarity 3 2 $t1_flair_mni  $mniTemplate $imSimFile
	echo "#t1_to_mni" >> $logFile
	cat $imSimFile >> $logFile
	endTime=$(date)
	echo "#done $endTime" >> $logFile
	rm $imSimFile
    fi

    # write mask to png dir
    if [ ! -d $subjDir/png ]; then
	mkdir $subjDir/png
    fi
    pngFile=$subjDir/png/flair_mni_wm_mask.png
    mkPng $flair_mni $flairWmMask $pngFile
    
done

