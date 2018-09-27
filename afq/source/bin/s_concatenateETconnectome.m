function s_concatenateETconnectome

%fgFileName{1} = '2million_2p9.tck';
fgFileName{1} = '2million_5p7.tck';
fgFileName{2} = '2million_11p5.tck';
fgFileName{3} = '2million_23p1.tck';
fgFileName{4} = '2million_47p2.tck';
 numconcatenate = [2000000 2000000 2000000 2000000];
fname = 'NHP_pUM_ETCall_8million_cand.mat';
et_concatenateconnectomes(fgFileName, numconcatenate, fname) 
