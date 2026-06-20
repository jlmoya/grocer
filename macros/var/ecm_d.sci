function [result]=ecm_d();
 
// PURPOSE: demonstrate the use of ecm()
//         function to estimate an error correction model
// ---------------------------------------------
// usage: ecm_d()
// ----------------------------------------------
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/datajpl.dat')
 
nlag = 2;
result = ecm(nlag,'endo=[illinos;indiana;kentucky;michigan;ohio;pennsyvlania;tennesse;westvirginia]','exo_st=const')
 
endfunction
