function Y = quantile(X,p)
 
// PURPOSE: calculate the quantiles of variables X
// ------------------------------------------------------------
// INPUT:
// * X = a (n x r) matrix
// * p =a scalar or a (np x 1) vector of cumulative probability
//   values
// ------------------------------------------------------------
// OUPTUT:
// Y = a (np x r) matrix of quantiles
// ------------------------------------------------------------
// Copyright: Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
 
p=vec2col(p)
[nr,nc]=size(X)
np=size(p,1)
Y=ones(np,nc)
for i=1:nc
   Xi=gsort(X(:,i),'g','i')
   pint=0.5+p*nr
   p1=floor(pint)
   p2=ceil(pint)
   w=p2-pint
   p1(pint<1)=1
   p2(pint>nr)=nr
   Y(:,i)=w .* Xi(p1) + (1-w) .*Xi(p2)
end
 
endfunction
