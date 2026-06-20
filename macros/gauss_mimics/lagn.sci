function y = lagn(x,t)
 
// PURPOSE: mimic gauss function lagn: lags a matrix a
// specified number of time periods for time series analysis
// ------------------------------------------------------------
// INPUT:
// * x = a (N x k) matrix
// * t = scalar, number of time periods
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x K) matrix, x lagged t period
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
if n > 0 then
   y=[x(1:t,:)*%nan ; x(1:$-t,:)]
else
   y=[x(t+1:$) ; x(1:t,:)*%nan ]
end
 
endfunction
