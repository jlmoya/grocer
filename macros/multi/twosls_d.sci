function [rt]=twosls_d()
// PURPOSE: An example twosls
//
//---------------------------------------------------
// USAGE: tsls_d
//---------------------------------------------------
//
 
 
nobs = 200;
//
x1 = rand(nobs,1,'n');
x2 = rand(nobs,1,'n');
b1 = 1;
b2 = 1;
iota = ones(nobs,1);
//
y1 = zeros(nobs,1);
y2 = zeros(nobs,1);
evec = rand(nobs,1,'n');
//
// create simultaneously determined variables y1,y2
for i = 1:nobs
  y1(i,1) = iota(i,1)*1+x1(i,1)*b1+evec(i,1);
  y2(i,1) = iota(i,1)*1+y1(i,1)*1+x2(i,1)*b2+evec(i,1);
end
 
result2 = iv('y2','endo=y1','exo=iota;x2','ivar=iota;x1;x2');
rt=twosls('y1=a+b*x1','y2=d+e*(y1-x2)+f*x2','coef=a;b;d;e;f')
 
endfunction
