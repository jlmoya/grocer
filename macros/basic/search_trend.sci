function ind_trend=search_trend(x)
 
// PURPOSE: find the indexes of the trend columns in a matrix
//-------------------------------------------------------------------
// INPUT:
// x = a (n x k) real matrix
//-------------------------------------------------------------------
// OUTPUT:
// ind_trend= a (p x 1) vector of integers
//-------------------------------------------------------------------
// Copyright E. Dubois (2009)
// http://grocer.toolbox.free.fr/grocer.html
 
 
absdx=abs(x(3:$,:)-x(2:$-1,:))
absd2x=abs(x(3:$,:)-2*x(2:$-1,:)+x(1:$-2,:))
sumc_absdx=sum(absdx,'r')
sumc_absd2x=sum(absd2x,'r')
ind_trend=find(sumc_absd2x == 0 & sumc_absdx ~= 0)
 
endfunction
 
