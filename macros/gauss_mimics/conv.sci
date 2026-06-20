function z=conv(b,x,f,l)
 
// PURPOSE: mimic Gauss function conv: computes the
// convolution of two vectors
// ------------------------------------------------------------
// INPUT:
// * b = (N x 1) vector
// * x = (L x 1) vector
// * f = scalar, the first convolution to compute
// * l = scalar, the last convolution to compute
// ------------------------------------------------------------
// OUTPUT:
// * z = (Q x 1)  result, where Q = (l ? f + 1) .
//   - If f is 0, the first to the l-th convolutions are
//     computed
//   - If l is 0, the f-th to the last convolutions are
//     computed
//   - If f and l are both zero, all the convolutions are
//     computed
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
[rx,cx]=size(x)
[ry,cy]=size(y)
 
if cx ~= cy & cy ~= 1 & cx ~= 1 then
   error('matrices are not comformable')
end
 
z=zeros(rx+ry-1,cx+cy-1)
for i=1:cx+cy-1
   z(:,i)=convol(x(:,min(i,cx)),y(:,min(i,cy)))'
end
 
if f ~=0 | l~=0 then
   z=z(max(f,1):min(l,rx-ry+1),:)
end
 
endfunction
