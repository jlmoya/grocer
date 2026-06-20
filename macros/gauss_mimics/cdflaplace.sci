function y = cdflaplace(x,a,b)
 
// PURPOSE: mimic Gauss function cdfLaplace: computes the
// cumulative distribution function of the Laplace distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (nx x mx) matrix
// * a = a (na x ma) matrix "conformable" to x
// * b = a (nb x mb) matrix "conformable" to x
// ------------------------------------------------------------
// OUTPUT:
// * y = a (max(nx,na,n) x max(mx,ma,mb)) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[x,a,b]=resize(x,a,b)
y=x
ind=(x <= a)
y(ind)=0.5*exp(-b(ind).*(a(ind) -x(ind)))
ind=(x > a)
y(ind)=1-0.5*exp(-b(ind).*(a(ind) -x(ind)))
 
 
endfunction
 
