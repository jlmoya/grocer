function g = cdfgam_gauss(x,intlim)
 
// PURPOSE: mimic Gauss function cdfgam: computes the
// complement of the cumulative distribution function of the F
// distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (nx x mx) matrix
// * intlim = a (L x M) matrix "conformable" to x
// ------------------------------------------------------------
// OUTPUT:
// * g = a (max(nx,L) x max(mx,M)) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
if or(x<=0) then
   error('first arg should be positive')
end
if or(intlim<=0) then
   error('first arg should be negative')
end
 
[x,intlim]=resize(x,intlim)
[g,Q]=cdfgam("PQ",intlim,x,0*x+1)
 
endfunction
 
