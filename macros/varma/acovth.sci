function ac= acovth(a,b,s,m);
 
// PURPOSE: theoretical acf for lags 0 to m for arma(p,q)-
// process.
// ------------------------------------------------------------
// INPUT:
// * s = variance of error process
// * a =(p,1) vector of ar-coef.: 1-a[1]b-..-a[p]b^p
// * b: (q,1) vector of ma-coef.: 1-b[1]b-..-b[q]b^q
// * m = number of lags
// ------------------------------------------------------------
// OUTPUT:
// * ac = a ((m+1)x1) vector containing the variance and the
//   m first autocovariances
// ------------------------------------------------------------
// NOTE: use a=0 / b=0 for pure ma- / ar-processes
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
a=vec2col(a)
b=vec2col(b)
p=rows(a);
q=rows(b);
m1=max(p,q+1)+1;
 
a1= reshape_gauss([1 (-a') zeros(1,m1+p+1)],m1,m1+2*p+3);
a1(2:m1,(2*p+4):(m1+2*p+2))=rev(a1(2:m1,(2*p+4):(m1+2*p+2))')';
a1=a1(:,1:m1)+a1(:,(2*p+3):(m1+2*p+2));
 
c = [mainf(a,[1 ; -b],q+1)]
c = reshape_gauss([c' zeros(1,q+1)],q+1,2*q+1);
c = [c(:,1:(q+1))*[1;-b] ; zeros(m1-q-1,1)]
ac = s*inv(a1)*c
 
for i= m1:m
      ac=[ ac ; a'*ac(seqa(i,-1,p),1) ]
end
 
ac=ac(1:m+1);
 
endfunction
 
