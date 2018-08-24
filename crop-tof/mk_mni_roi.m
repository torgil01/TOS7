% Make Circle of Willis VOI in MNI space
% require spm 

% Load MNI volume header
template='MNI152_T1_1mm.nii.gz';
gunzip(template);
template = replaceExt(template,'.nii');
V = spm_vol(template);

% create empty volume with MNI dimensions 
img = zeros(V.dim);
%img(42:142,67:151,18:73) = 1;
img(52:134,92:154,23:78) = 1;

Vout = rmfield(V,'pinfo');
Vout.fname='mni_roi2.nii';
spm_write_vol(Vout,img);
delete(template);





