function preproc(t1,flair)
% preproc

mni_template = fullfile(spm('dir'),'canonical/avg152T1.nii');


% 1 t1 <- flair coreg
opt.cost_fun = 'nmi';
%myspm_coreg(flair,t1,opt);

% 2 t1 -> template coreg
opt.cost_fun = 'nmi';
opt.other = {flair};
myspm_coreg(t1,mni_template,opt);

% 3. segment 
myspm_segment(t1);

% 4 mask 
[t1Dir,~] = fileparts(t1);
gmFile = addInFront(t1,'c1');
wmFile = addInFront(t1,'c2');
csfFile = addInFront(t1,'c3');
maskFile = fullfile(t1Dir,'brainmask.nii');

imcalc({gmFile,wmFile,csfFile},maskFile,'i1+i2+i3>0.5');

% skullstrip flair
[flairDir, ~] = fileparts(flair);
flairBrainFile = fullfile(flairDir,'flair_brain.nii');
imcalc({maskFile,flair},flairBrainFile,'i1.*i2');

%maskImage(flair,flairBrainFile,maskFile);

% get mean gm value in flair
% mk gm mask
gmMaskFile = fullfile(t1Dir,'gmMask.nii');
mkMask(gmFile,gmMaskFile,0.5);
gmFlairFile = fullfile(flairDir,'gmFlair.nii');
imcalc({gmMaskFile,flair},gmFlairFile,'i1.*i2');

V=spm_vol(gmFlairFile);
gmFl = spm_read_vols(V);
gmFlair = gmFl(gmFl > 0);
meanVal = mean(gmFlair(:));


% n4 bias 
corrected = addInFront(flairBrainFile,'n4_');
N4BiasFieldCorrection(flairBrainFile,corrected)

% scale flair
V=spm_vol(corrected);
flair = spm_read_vols(V);

flair = 200*flair./meanVal;
Vout = rmfield(V,'pinfo');
Vout.fname = fullfile(flairDir,'flair_n4_scaled.nii');
spm_write_vol(Vout,flair);








