function y=cdffc(x,n1,n2)
 
// PURPOSE: mimics gauss function cdffc: computes the
// complement of the cumulative distribution function of the F
// distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (nx x mx) matrix
// * n1 = a (na x ma) matrix "conformable" to x
// * n2 = a (nm x mm) matrix "conformable" to x
// ------------------------------------------------------------
// OUTPUT:
// * y = a (max(nx,na,nm) x max(mx,ma,mm)) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[x,n1,n2]=resize(x,n1,n2)
[P,y]=cdff("PQ",x,n1,n2)
 
endfunction
 
