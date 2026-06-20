function mat=invvech(v,nr)
 
// Purpose: retrieve from a matrix vectorized by vech the
// original matrix
// ------------------------------------------------------------
// INPUT:
// * v = a (nrx1) vector
// * nr = # of rows of the original matrix (optional: if it is
// not provided, the function determines it)
// ------------------------------------------------------------
// OUTPUT:
// * mat = the original -vectorized by vech- matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2003-2005
// http://grocer.toolbox.free.fr/grocer.html
 
[nargin,nargout]=argn(0)
[N,p]=size(v)
 
if p ~= 1 then
   error('1st arg should be a column vector')
end
 
if nargin ==1 then
   nr=(sqrt(1+8*N)-1)/2
   mat=zeros(nr,nr)
elseif N ~= nr*(nr+1)/2 then
   error('size of arg 1 and arg2 not conformable')
end
 
mat=invvech1(v,nr)
 
endfunction
 
