function [val,p]=lratio0(r0,ra)
 
// PURPOSE: computes the log-likehood ratio of two models
// ------------------------------------------------------------
// INPUT:
// * r0 = results tlist from restricted regression
// * ra = results tlist from unrestricted regression
// ------------------------------------------------------------
// OUTPUT:
// * val = the value of the log-likelihood ratio
// * p = the corresponding p-values
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
llike0=real(r0('llike'))
llikea=real(ra('llike'))
if llike0 >= llikea then
   llkiek0=llike0-2*%eps
end
val=2*(ra('llike')-r0('llike'))
p=1 - cdfchi("PQ",val,sum(ra('nvar'))-sum(r0('nvar')))
 
endfunction
