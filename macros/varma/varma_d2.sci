function results=varma_d2()
 
global GROCERDIR;
 
 
load(GROCERDIR+'/data/varma_d.dat');
 
y = transdif(seriesb,0,1,1,12);
 
 
// impose that the MA parameter is greater than -0.98
results=varma('y',[],[],0,0,0,12)
results=varma('y',[],[],['-1<1'],['-0.98<'],0,12)
 
endfunction
 
