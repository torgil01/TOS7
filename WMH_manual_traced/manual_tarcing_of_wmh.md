# Manual tracing of WMH
Flair images were divided into three age groups (40-55),(56-70) and (71-85) and 5 from each gender were selected from each age group giving 30 images total.

To ease the manual segmentation, the FLAIR images were skull stripped, corrected for intensity nonuniformity and scaled to a mean of 100. See `preproc.m`and `doPreporc.m`.


WMH was traced with Mango software according to defined criteria by one rater. Coordinate space was set to "world" when tracing (http://ric.uthscsa.edu/mango/mango_guide_toolbox.html) which resulted in some problems when attempting to overlay the WMH tracing in the original FLAIR images.


Thise issues are fixed by the `fixRoi.m`and `swapHdr.sh`scrips. The two must be run in succession.




