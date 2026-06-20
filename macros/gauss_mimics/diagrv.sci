function y=diagrv(x,v)
 
// PURPOSE: mimic gauss function diagrv: puts a column vector
// into the diagonal of a matrix
// ------------------------------------------------------------
// INPUT:
// * x = (N x K) matrix.
// * v = min(N,K) x 1 vector
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x K) matrix equal to x except for its principal
// diagonal elements equal to those of v.
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nr,nc]=size(y)
b=eye(nr,nc)
y(b == 1)=v
 
endfunction
