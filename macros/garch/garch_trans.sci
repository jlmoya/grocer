function [param]=garch_trans(param,k)
 
// PURPOSE: function to transform the a0,ar(p),ma(q) parameters
// parameters of a garch(p,q)
// ------------------------------------------------------------
// INPUT:
// * param = [b ; a0 ; ar ; ma]
// * k = size(b,1)
// ------------------------------------------------------------
// OUTPUT:
// the same, but transformed
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
param(k+1)=param(k+1)^2
nparam=size(param,1)
s=sum(exp(param(k+2:nparam)))+1
param(k+2:nparam)=exp(param(k+2:nparam))/s
 
endfunction
