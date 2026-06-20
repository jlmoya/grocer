function [y]=norm_rnd(sig,n,seed)
 
// PURPOSE: random multivariate vector based on  var-cov
//         matrix sig
// ------------------------------------------------------------
// INPUT:
// * sig = a square-symmetric covariance matrix
// * n = number of draws
// * seed = the seed to grand (optional)
// ------------------------------------------------------------
// OUTPUT:
// y = random vector normal draw mean 0, var-cov(sig)
// ------------------------------------------------------------
// NOTES:
// * for mean b, var-cov sig use: b +  norm_rnd(sig)
// * since the Scilab version 2.7, this function is -almost-
//   useless since the function grand now allows to draw
//   random multivariate vector; the advantage of this function
//   is however that it uses Bruno Pinçon's trick to generare
//   a seed if the user does not want to bother giving one
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin < 3 then
   v=getdate()
   grand('setsd',sum(v([2 6 7 8 9])))
else
   grand('setsd',seed)
end
 
y = grand(n,'mn',zeros(size(sig,1),1),sig)
 
endfunction
