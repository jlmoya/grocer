function results=varma_d3()
 
global GROCERDIR;
 
 
load(GROCERDIR+'/data/varma_d.dat');
 
y = transdif(seriesc,0,1,1,12);
 
results=varma(y,[],[],0,0,0,12)
 
endfunction
 
