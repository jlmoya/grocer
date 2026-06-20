function b=null_gauss(x)
 
// PURPOSE: mimic Gauss function null: computes an orthonormal
// basis for the (right) null space of a matrix
// ------------------------------------------------------------
// INPUT:
// * x = (M x M) matrix
// ------------------------------------------------------------
// OUTPUT:
// * b =  (M x K) matrix, matrix, where K is the nullity of x,
//      such that:
//        x * b = 0 ( (N x K) matrix of zeros )
//            and
//        b'*b = I ( (MxM) identity matrix )
//     = error tlist if x is estimated full rank
// ------------------------------------------------------------
// NOTE:
// Since this is a numerical programm, there can be cases where
// gauss will return an error and Scilab not (and conversely)
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[u,d,v]=svd(x)
n=size(v,1)
zero=%T
i=n
b=[]
 
while i>0 & zero then
   zero=(abs(d(i,i))/max(abs(d))) < %eps
   i=i-1
end
b=v(:,i+2:n)
 
if isempty(b) then
   b=tlist(['error';'error number'],1)
end
 
endfunction
