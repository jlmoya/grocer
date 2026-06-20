function [contrib_x]=contrib(vari,mainf_proxy,dropna)
 
// PURPOSE: Calculates contribution of variable vari to the
// evolution of an endogenous variable, with response function
// mainf_proxy
// ------------------------------------------------------------
// INPUT:
// * vari = the exogenous varaible, either a ts, a vector or
//   such an object
// * mainf_proxy = the nbterms first terms of the Infinite
// Moving average
// * dropna = 'dropna' if the user wants to remove the NA
//     values from the data (optional)
// ------------------------------------------------------------
// OUTPUT:
// * contrib_x = the vector or ts of contributions
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003-2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin ==2 then
   dropna=%f
end
 
// explode namey into the corresponding variable, its name, if
// it's a ts and if necessary the admissible bounds
[y,namey,prests,boundsvarb,nonna]=explone(vari,[],'endogenous',%t,dropna)
 
nobs=size(y,1)
nbmainf=size(mainf_proxy,1)
 
if nobs >  nbmainf then
   warning('# of terms in the response function are lower than the # of observations')
end
 
contrib_x=ones(nobs,1)
for i=1:nobs
   j=min(i,nbmainf)
   contrib_x(i)=y(1+i-j:i)'*mainf_proxy(j:-1:1)
end
 
if prests then
   contrib_x=vec2ts(contrib_x,boundsvarb)
end
 
endfunction
