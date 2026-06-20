function y = polyint(xa,ya,x);
 
// PURPOSE: mimic gauss function polyint: calculates an Nth
// order polynomial interpolation
// ------------------------------------------------------------
// INPUT:
// * xa = a (N x 1) vector
// * ya = a (N x 1) vector
// * xscalar, X value to solve for
// ------------------------------------------------------------
// OUTPUT:
// * y = result of interpolation or extrapolation
// ------------------------------------------------------------
// NOTE: the result can be numerically slightly different from
// Gauss result, because Grocer function does not manage as
// Gauss one the order of the polynom and the precision
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
n = max(size(xa))
m = max(size(ya));
 
if n~=m then
  disp("neville error: number of ordinates and number of function values must be equal")
  return;
end;
 
temp = ya;
for j = 2:n
  for i = n:-1:j
    temp(i) = ( (x-xa(i-j+1))*temp(i) - (x-xa(i))*temp(i-1) ) / ...
		          ( xa(i) - xa(i-j+1) );
  end;
end;
y=temp(n)
 
endfunction
