function n4Correct(imgDir)

files = findFiles(imgDir,'flair_scaled.nii');
for i=1:length(files),
    corrected = addInFront(files{i},'n4_');
    N4BiasFieldCorrection(files{i},corrected)
end
