function mat=invvech1(v,nr)
 
// Purpose: retrieve from a matrix vectorized by vech the
// original matrix
// ------------------------------------------------------------
// INPUT:
// * v = a (nrx1) vector
// * nr = # of rows of the original matrix
// ------------------------------------------------------------
// OUTPUT:
// * mat = the original -vectorized by vech- matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
mat=zeros(nr,nr)
N=size(v,1)
 
for i=1:nr
   mat(nr-i+1:nr,nr-i+1)=v(N-i*(i+1)/2+1:N-i*(i-1)/2)
end
mat=mat+tril(mat,-1)'
 
endfunction
 
