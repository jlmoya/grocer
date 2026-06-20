function results=varma_d1()
 
global GROCERDIR;
 
// *** Series A. First read and transform the data
load(GROCERDIR+'/data/varma_d.dat');
 
elec_cons = transdif(seriesa,0,1,1,12);
 
results=varma(elec_cons,[],[],1,1,1,12)
 
endfunction
 
