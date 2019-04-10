#!/bin/bash

subjDir=$1
studies=$(find $subjDir -mindepth 1 -maxdepth 1 -type d )

for study in ${studies[@]}; do
    subDir=$(find $study -mindepth 1 -maxdepth 1 -type d)
    #dcmFile=$(find ${subDir[0]} -type f -name *.dcm -print -quit)
    dcmFile=$(find ${subDir[0]} -type f -print -quit)
    id=$(basename $study)
    
    # parse dicom 

    patientName=$(dcmdump +f $dcmFile +P 0010,0010 | cut -d "[" -f2 | cut -d "]" -f1)
    patientID=$(dcmdump +f $dcmFile +P 0010,0020 | cut -d "[" -f2 | cut -d "]" -f1)
    studyDate=$(dcmdump +f $dcmFile +P 0008,0022 | cut -d "[" -f2 | cut -d "]" -f1)
    studyTime=$(dcmdump +f $dcmFile +P 0008,0032 | cut -d "[" -f2 | cut -d "]" -f1)
    patientAge=$(dcmdump +f $dcmFile +P 0010,1010 | cut -d "[" -f2 | cut -d "]" -f1)
    patientSex=$(dcmdump +f $dcmFile +P 0010,0040 | cut -d "[" -f2 | cut -d "]" -f1)
    patientDob=$(dcmdump +f $dcmFile +P 0010,0040 | cut -d "[" -f2 | cut -d "]" -f1)

    # coil
    cc=$(strings $dcmFile | grep -m 1 HeadNeck_64)
    cc=${cc#*'""'}
    cc=${cc%*'""'}    
    mriCoil=$cc

    echo "$id;$patientName;$patientID;$patientAge;$studyDate;$studyTime;$mriCoil"

done


# (0008,0020) DA [20170211]                               #   8, 1 StudyDate
# (0008,0021) DA [20170211]                               #   8, 1 SeriesDate
# (0008,0022) DA [20170211]                               #   8, 1 AcquisitionDate
# (0008,0023) DA [20170211]                               #   8, 1 ContentDate
# (0008,0030) TM [140222]                                 #   6, 1 StudyTime
# (0008,0031) TM [142859.965000]                          #  14, 1 SeriesTime
# (0008,0032) TM [142756.937500]                          #  14, 1 AcquisitionTime
# (0008,0033) TM [142859.968000]                          #  14, 1 ContentTime
# (0010,0020) LO [17.02.11-14:02:02-STD-1.3.12.2.1107.5.2.19.45670] #  48, 1 PatientID
# (0010,0030) DA (no value available)                     #   0, 0 PatientBirthDate
# (0010,0040) CS [F]                                      #   2, 1 PatientSex
# (0010,1010) AS [049Y]                                   #   4, 1 PatientAge
