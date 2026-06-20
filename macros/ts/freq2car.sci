function car=freq2car(f)
 
// PURPOSE: transforms a frequency in the corresponding string
// ------------------------------------------------------------
// INPUT:
// * f= a frequency
// ------------------------------------------------------------
// OUTPUT:
// * car = a string
// ------------------------------------------------------------
// NOTE: must be extended if one wants to introduce a new
// default frequency
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2005
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
load(GROCERDIR+'\param\basets.dat')
 
[i,j]=find(grocer_basefqnum == f)
car=grocer_basefqlit(i,:)
 
endfunction
