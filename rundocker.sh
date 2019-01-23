dataDir="/black/localhome/glerma/TESTDATA/AFQ_PIPELINE"
docker run -ti --rm  \
	       -v $dataDir/input:/flywheel/v0/input  \
   	       -v $dataDir/output:/flywheel/v0/output  \
   	       scitran/afq-pipeline:$1
