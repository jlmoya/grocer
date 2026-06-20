function y=cdfexp(x,a,m)
 
// PURPOSE: mimic Gauss function cdfexp: computes the
// cumulative distribution function for the exponential
// distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (nx x mx) matrix
// * a = a (na x ma) matrix "conformable" to x
// * m = a (nm x mm) matrix "conformable" to x
// ------------------------------------------------------------
// OUTPUT:
// * y = a (max(nx,na,nm) x max(mx,ma,mm))
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[x,a,m]=resize(x,a,m)
y=1-exp((x-a) ./ m)
 
endfunction
 
