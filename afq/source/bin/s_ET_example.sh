# Perform CSD-based probabilistic tractography, 5 million
#mrconvert t1_class_binary.nii.gz t1_class_MDthreshold.mif

tckgen ODF.mif 2million_11p5.tck -mask t1_class_MDthreshold.mif -seed_image t1_class_MDthreshold.mif -minlength 10 -maxlength 250 -angle 11.5 -number 2000000 -nthreads 16
tckgen ODF.mif 2million_47p2.tck -mask t1_class_MDthreshold.mif -seed_image t1_class_MDthreshold.mif -minlength 10 -maxlength 250 -angle 47.2 -number 2000000 -nthreads 12
tckgen ODF.mif 2million_23p1.tck -mask t1_class_MDthreshold.mif -seed_image t1_class_MDthreshold.mif -minlength 10 -maxlength 250 -angle 23.1 -number 2000000 -nthreads 12
tckgen ODF.mif 2million_5p7.tck -mask t1_class_MDthreshold.mif -seed_image t1_class_MDthreshold.mif -minlength 10 -maxlength 250 -angle 5.7 -number 2000000 -nthreads 12
tckgen ODF.mif 2million_2p9.tck -mask t1_class_MDthreshold.mif -seed_image t1_class_MDthreshold.mif -minlength 10 -maxlength 250 -angle 2.9 -number 2000000 -nthreads 12
