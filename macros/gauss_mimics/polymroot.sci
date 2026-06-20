function r = polymroot(c)
 
// PURPOSE: mimic gauss function polymroot: computes the roots
// of the determinant of a matrix polynomial
// ------------------------------------------------------------
// INPUT:
// * c = ((N+1)*K x K) matrix of coefficients of an Nth order
//   polynomial of rank K
// ------------------------------------------------------------
// OUTPUT:
// * r = K*N vector containing the roots of the determinantal
//   equation
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
k=size(c,2)
N=size(c,1)/k-1
 
x=poly(0,'x')
p=c(N*k+1:(N+1)*k,:)
for i=N-1:-1:0
   p=p+c(i*k+1:(i+1)*k,:)*x^(N-i)
end
c=roots(detr(p))
 
 
endfunction
