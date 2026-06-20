function [xmat]=ptrend(p,nobs)
 
// PURPOSE: produce an explanatory variables matrix
//          containing a polynomial time-trend
// ------------------------------------------------------------
// INPUT:
// * p = order of the time-trend polynomial
//   . p < 0, xmat = empty vector
//   . p = 1, xmat = time trend
//   . p > 1, xmat = higher order polynomial in time
// * nobs = size of the matrix
// ------------------------------------------------------------
// OUTPUT:
// xmat = matrix containing polynomial trend model data set
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// adapted -very freely !- from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatia-econometrics.com
 
 
xmat = [];
t = [1:nobs]';
for i=1:p+1
   xmat=[xmat t.^(i-1)]
end
 
endfunction
 
