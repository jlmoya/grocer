function [xx,f] =kerndens(x,positive,h,kernelt)
 
// PURPOSE: Draw a nonparametric density estimate.
//---------------------------------------------------
// USAGE: [h f y] = pltdens(x,p,h,kernelt)
//        or pltdens(x) which uses gaussian kernel default
// where:
// . x is a vector
// . h is the kernel bandwidth
// . default=1.06 * std(x) * n^(-1/5); Silverman page 45
// . p is 1 if the density is 0 for negative values
// . kernelt is the kernel type:
//   =1 Gaussian
// 		=2 Epanechnikov (default)
// 	 =3 Biweight
// 		=4 Triangular
//---------------------------------------------------
// RETURNS:
// xx = the interval used
// f = the density
// --------------------------------------------------
//
//  Anders Holtsberg, 18-11-93
//  Copyright (c) Anders Holtsberg
//  Translated by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn()
 
x =x(:)
n = size(x,1)
 
if nargin<4 then
  kernelt = 1
end
if nargin<3 then
	h = (1.06*(st_dev(x,1)))*(n^(-1/5))  // Silverman page 45
end
if nargin<2 then
  positive = 0
end
 
if positive & or(x < 0) then
  error("There is a negative element in X")
end
 
mn1 = min(x)
mx1 = max(x)
mn = mn1 - (mx1-mn1)/3
mx = mx1 + (mx1-mn1)/3
grid = 256
 
xx = linspace(mn,mx,grid)'
d = xx(2)-xx(1)
xh = zeros(size(xx,1),1)
 
xa = (x-mn)/(mx-mn)*grid
for i = 1:n
  il = floor(xa(i))
  a = xa(i)-il
	xh(il+[1 2]) = xh(il+[1 2])+[1-a, a]'
end;
xk = (-grid:grid-1)'*d
 
if kernelt == 1
   K = exp(-0.5*(xk/h).^2)
 
elseif kernelt == 2
   K = max(0,1-(xk/h).^2/5)
 
elseif kernelt == 3
   c = sqrt(1/7)
   K = (1-(xk/h*c).^2).^2 .* ((1-abs(xk/h*c)) > 0)
 
elseif kernelt == 4
   c = sqrt(1/6);
   K = max(0,1-abs(xk/h*c))
end
 
K = K/((sum(K,1)*d)*n)
 
[nxh kxh] = size(xh)
f = fft(fft(fftshift(K),-1).*fft([xh ;zeros(nxh,kxh)],-1),1)
f = real(f(1:grid))
 
if positive
   m = sum(xx<0,1);
   f(m+(1:m)) = f(m+(1:m)) + f(m:-1:1);
   f(1:m) = zeros(size(f(1:m),1),size(f(1:m),2));
   xx(m+[0 1]) = [0 0];
end
 
 
 
 
 
endfunction
