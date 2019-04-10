# FreeSurfer related code

# Checking for competed FreeSurfer jobs

```bash
checkFSJobs.sh SUBJECTS_DIR
```

# Compile FreeSurfer statistics

Set `dataDir` in script to `SUBJECTS_DIR`. Aseg, and aparc stats will be written to current dir. 

```bash
get_fs_stats.sh
```

# Collect SNR and CNR data
Estimates of SNR and CNR (on T1w images) are collected from the FreeSurfer data using `wm-anat-snr` cor SNR and `mri_cnr` for CNR. 

```bash
snr_calc.sh SUBJECTS_DIR
```


