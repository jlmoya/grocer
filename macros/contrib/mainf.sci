function [mainf_proxy]=mainf(ar,ma,nbterms)
 
// PURPOSE: Infinite Moving average representation of an ARMA
// process, supposed to be written:
// (1-ar(L))xt = ma(L) ut
// ------------------------------------------------------------
// INPUT:
// * ar= the ar part = a (px1) or (1xp) vector
// * ma = the ma part = a (qx1) or (1xq) vector
// * nbterms = # of terms developped (optional, default = 100)
// ------------------------------------------------------------
// OUTPUT:
// * mainf_proxy = the nbterms first terms of the Infinite
// Moving average representation
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin]=argn(0)
if nargin == 2 then
   nbterms=100
end
 
ar = vec2col(ar)
ma = vec2col(ma)
nb_ar = size(ar,1)
nb_ma = size(ma,1)
 
mainf_proxy = ones(nbterms,1)
mainf_proxy(1) = ma(1)
// the ma terms enter only the first nb_ma recurrence equations
for i=2:nb_ma
   nbmin=min(i-1,nb_ar)
   mainf_proxy(i) = ma(i)+mainf_proxy(i-1:-1:i-nbmin)'*ar(1:nbmin)
end
 
for i=nb_ma+1:nbterms
   nbmin=min(i-1,nb_ar)
   mainf_proxy(i) = mainf_proxy(i-1:-1:i-nbmin)'*ar(1:nbmin)
end
endfunction
