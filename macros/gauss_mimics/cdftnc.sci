function y = cdftnc(x,v,d)
 
// PURPOSE: mimic Gauss function cdftnc: the integral under
// noncentral Student’s t distribution, from -%inf to x.
// ------------------------------------------------------------
// INPUT:
// * x = a (N x 1) vector, values of upper limits of integrals
// * v = scalar, degrees of freedom, v > 0
// * d = scalar, noncentrality parameter
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x 1) vector, integrals from ?1 to x of noncentral t
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[P0,Q0]=cdffnc("PQ",0,1,v,d^2)
[P,Q]=cdffnc("PQ",x .^ 2,1+0*x,v+0*x,d^2+0*x)
y=P0*(x>0)+0.5*P
 
endfunction
