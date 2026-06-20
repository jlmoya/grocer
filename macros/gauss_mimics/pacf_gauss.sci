function rkk = pacf_gauss(y,k,d)
 
// PURPOSE: fmimics gauss function pacf: computes sample
// partial autocorrelations
// ------------------------------------------------------------
// INPUT:
// * y = a real (N x 	1) vector
// * m = a scalar, the # of calculated coefficients
// * d = scalar, order of differencing
// ------------------------------------------------------------
// OUTPUT:
// rkk = (K x 1) vector, sample partial autocorrelations
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
for i=1:d
   y=[y(2:$)-y(1:$-1)]
end
 
n = size(y,1);
rkk = zeros(k,1);
npm = n+m;
 
// put y in deviations from mean form
e = zeros(npm,1);
e(1:n,1) = y-mean0(y)
 
f = crlag(e,npm);
 
for i = 1:k
  parti = f'*e/(f'*f);
  apart = -parti;
  tmp = e;
  e = tmp+apart*f;
  f = f+apart*tmp;
  f = crlag(f,npm);
  rkk(i) = parti;
end
 
 
endfunction
 
