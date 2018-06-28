#!/bin/bash
# module load matlab/2017a

cat > build.m <<END

addpath(genpath('/data/localhome/glerma/soft/AFQ'));
addpath(genpath('/data/localhome/glerma/soft/afq-pipeline'));
addpath(genpath('/data/localhome/glerma/soft/vistasoft'));
addpath(genpath('/black/localhome/glerma/soft/spm8'));
addpath(genpath('/data/localhome/glerma/soft/jsonlab'));
addpath(genpath('/data/localhome/glerma/soft/encode'));
addpath(genpath('/data/localhome/glerma/soft/JSONio'));
addpath(genpath('/data/localhome/glerma/soft/app-life'));

mcc -m -R -nodisplay -d compiled main
exit
END
Matlabr2017a -nodisplay -nosplash -r build && rm build.m





