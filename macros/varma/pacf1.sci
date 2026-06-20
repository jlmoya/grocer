function [respacf]=pacf1(y,m,s)
 
// PURPOSE: find sample partial autocorrelation coefficients
//---------------------------------------------------
// INPUT:
// * x = a a real (nx1) vector
// * m = a scalar, the # of calculated coefficients
// * s= the size of the confidence band
//---------------------------------------------------
// OUTPUT:
// respacf = a tlist with
//   . respacf('meth')   = 'pacf'
//   . respacf('y')      = values of the input variable
//   . respacf('pacf')   = partial autocorrelation coeffcients
//   . respacf('pacf_l') = low bound of the confidence interval
//   . respacf('pacf_u') = upper bound of the confidence interval
//   . respacf('size') = size of the confidence band
// --------------------------------------------------
// Copyright Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
n = size(y,1);
x = zeros(m,1);
npm = n+m;
 
// put y in deviations from mean form
e = zeros(npm,1);
e(1:n,1) = y-mean0(y)
 
f = crlag(e,npm);
 
for i = 1:m
  parti = f'*e/(f'*f);
  apart = -parti;
  tmp = e;
  e = tmp+apart*f;
  f = f+apart*tmp;
  f = crlag(f,npm);
  x(i) = parti;
end
 
bandsize=cdfnor("X",0,1,s/2,1-s/2)
ul = bandsize*(1/sqrt(n)*ones(m,1));
ll = -bandsize*(1/sqrt(n)*ones(m,1));
 
respacf=tlist(['results';'meth';'y';'pacf';'pacf_l';'pacf_u';...
'size'],...
'pacf',y,x,ll,ul,s)
 
 
endfunction
 
