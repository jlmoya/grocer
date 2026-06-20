function indcte=search_cte(x)
 
// PURPOSE: find the indexes of the constant columns in a matrix
//-------------------------------------------------------------------
// INPUT:
// x = a (n x k) real matrix
//-------------------------------------------------------------------
// OUTPUT:
// indcte= a (p x 1) vector of integers
//-------------------------------------------------------------------
// Copyright E. Dubois (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
 
absdx=abs(x(2:$,:)-x(1:$-1,:))
sumc_absdx=sum(absdx,'r')
indcte=find(sumc_absdx == 0)
 
endfunction
 
