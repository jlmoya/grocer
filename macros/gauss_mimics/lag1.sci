function y = lag1(x)
 
// PURPOSE: mimics gauss function lag1: Lags a matrix by one
// time period for time series analysis
// ------------------------------------------------------------
// INPUT:
// * x = a (N x k) matrix
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x K) matrix, x lagged 1 period
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
y=[x(1,:)*%nan ; x(1:$-1,:)]
 
endfunction
 
