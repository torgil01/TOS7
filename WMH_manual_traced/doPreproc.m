% 

flairFiles = findFiles('/home/torgil/Projects/WMH-PET/misbah/Images/work2','t2_flair_3d.nii');
t1Files = cell(length(flairFiles),1);
for i=1:length(flairFiles),
    [flairDir, ~] = fileparts(flairFiles{i});
    [baseDir, ~] = fileparts(flairDir);
    t1Files{i}= fullfile(baseDir,'T1_3D_SAG','t1_3d_sag.nii');
end

for i=1:length(flairFiles),
    preproc(t1Files{i},flairFiles{i});
end

