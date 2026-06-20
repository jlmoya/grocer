function rk = acf_gauss(y,k,d)
 
// PURPOSE: fmimics gauss function acf: Computes sample
// autocorrelations
// ------------------------------------------------------------
// INPUT:
// * y = a real (N x 	1) vector
// * k = a scalar, the # of calculated coefficients
// * d = scalar, order of differencing
// ------------------------------------------------------------
// OUTPUT:
// rk = (K x 1) vector, sample autocorrelations
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
for i=1:d
   y=[y(2:$)-y(1:$-1)]
end
 
[cov,Mean]=corr(y,k+1);
rk=cov(2:k+1)/cov(1);
 
endfunction
 
 
