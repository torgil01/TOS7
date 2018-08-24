function fixRoi
% fix Mango header issue
% setting for spm_imcalc
mask = 0;
dmtx = 0;
hold = 0; % NN interpol
flags = {dmtx,mask,hold};
roiDir='/home/torgil/Projects/WMH-PET/misbah/misbah_whh-seg/seg-rev/';
flairDir='/home/torgil/Projects/WMH-PET/misbah/misbah_whh-seg/flair_n4/';
roiFiles = findFiles(roiDir,'./*_roi.nii');

for i=1:length(roiFiles),     
    % name for flair
    [~, fn] = fileparts(roiFiles{i});
    %fn = rmExt(fn);
    flairFile = fullfile(flairDir,[fn(1:end-4) '.nii']);
    [~, fn2] =fileparts(fn);
    id = fn2(1:6);
    roiFix = fullfile(roiDir,[id '_roi_fix.nii']);
    
    Vf = spm_vol(flairFile);
    Vm = spm_vol(roiFiles{i});
    Vo = rmfield(Vf,'pinfo');
    Vo.fname = roiFix;

    Vi = cell2mat({Vf,Vm});
    spm_imcalc(Vi,Vo,'(i1.*0)+i2',flags);
end
