function mat=xpnd1(v,nr)
 
// Purpose: retrieve from a matrix vectorized by vech_gauss the
// original matrix
// ------------------------------------------------------------
// INPUT:
// * v = a (nr x 1) vector
// * nr = # of rows of the original matrix
// ------------------------------------------------------------
// OUTPUT:
// * mat = the original -vectorized by vech_gauss- matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2006
// http://grocer.toolbox.free.fr/grocer.html
 
mat=zeros(nr,nr)
 
for i=1:nr
   mat(1:i,i)=v(i*(i-1)/2+1:i*(i+1)/2)
end
mat=mat+triu(mat,1)'
 
endfunction
 
