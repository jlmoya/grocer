function result=varma_d4()
 
global GROCERDIR;
load(GROCERDIR+'/data/varma_d.dat');
 
seriesd = log(seriesd)/log(10);
y = transdif(seriesd,1,1,1,12);

bounds(); 
result=varma('y',0.8,[],[],0.6,0.1,12)
 
endfunction
