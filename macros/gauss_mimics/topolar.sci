function [r,theta] = topolar(xy)
 
// PURPOSE: mimic gauss function topolar: Converts from
// cartesian to polar coordinates
// ------------------------------------------------------------
// INPUT:
// * xy = (N x k) complex matrix containing the X coordinate in
//   the real part and the Y coordinate in the imaginary part (N x k) real matrix, radius
// ------------------------------------------------------------
// OUTPUT:
// * r = (N x k) real matrix, radius
// * theta = (N x k) real matrix, angle in radians
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
x=real(xy)
y=imag(xy)
r=sqrt(x .^2 + y .^2)
theta=atan(y ./x)
 
endfunction
