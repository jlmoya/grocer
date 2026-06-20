function y=cdfbeta(x,a,b)
 
// PURPOSE: mimic Gauss function cdfbeta: computes the
// cumulative distribution function of the beta distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (nx x mx) matrix
// * a = a (na x ma) matrix "conformable" to x
// * b = a (nb x mb) matrix "conformable" to x
// ------------------------------------------------------------
// OUTPUT:
// * matin = a (a (max(nx,na,n) x max(mx,ma,mb)) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[x,a,b]=resize(x,a,b)
y=cdfbet("PQ",x,1-x,a,b)
 
endfunction
 
