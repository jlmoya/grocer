function d=date_gauss()
 
// PURPOSE: mimic gauss function date: returns the current
// date in a 4-element column vector, in the order: year,
// month, day, and hundredths of a second since midnight
// ------------------------------------------------------------
// INPUT:
// NONE
// ------------------------------------------------------------
// OUTPUT:
// * d = a (4 x 1) vector
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
x=getdate()
d=[x(1:2),x(6),(x(7)*3600+x(8)*60)*100+x(10)*0.1]'
 
 
endfunction
 
