function y = cdfgenpareto(x,a,o,k)
 
// PURPOSE: mimic Gauss function cdfGenPareto: computes the
// complement of the cumulative distribution function for the
// Generalized Pareto distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (nx x mx) matrix
// * a = a (na x ma) matrix "conformable" to x
// * o = a (no x mo) matrix "conformable" to x
// * k = a (nk x mk) matrix "conformable" to x
// ------------------------------------------------------------
// OUTPUT:
// * y = a (max(nx,na,no,nk) x max(mx,ma,mo,mk)) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[x,a,o,k]=resize(x,a,o,k)
y=x
y(k == 0)=1-exp((x(k==0) -a(k==0)) ./ o(k==0))
y(k ~= 0)=1-(1+k(k~=0).*(x(k~=0) -a(k~=0)) ./ o(k~=0)) .^ (-1 ./k(k~=0))
 
 
endfunction
 
