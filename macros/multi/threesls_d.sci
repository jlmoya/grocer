function [r]=threesls_d()
 
 
nobs = 100;
neqs = 3;
 
x1 =  rand(nobs,1,'n')
x2 =  rand(nobs,1,'n')
x3 =  rand(nobs,1,'n')
iota = ones(nobs,1);
 
y1 = zeros(nobs,1);
y2 = zeros(nobs,1);
y3 = zeros(nobs,1);
evec =  rand(nobs,3,'n')
evec(:,2) = evec(:,3) +  rand(nobs,1,'n')
// create cross-eqs corr
 
// create simultaneously determined variables y1,y2
for i=1:nobs
y1(i,1) = iota(i,1)*10.0 + x1(i,1)*1 + evec(i,1);
y2(i,1) = iota(i,1)*10.0 + y1(i,1)*0.5 + x2(i,1)*2 + evec(i,2);
y3(i,1) = iota(i,1)*10.0 + y2(i,1)*1.5 + x2(i,1)*3 + x3(i,1)*4 + evec(i,3);
end;
 
r=threesls('y1=a1+b1*x1','y2=a2+b2*x2+c2*y1','y3=a3+b3*x3+c3*y2+d3*x2',...
'coef=a1;a2;a3;b1;b2;b3;c1;c2;c3;d3')
endfunction
