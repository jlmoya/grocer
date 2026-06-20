function xy = tocart(r,theta)
 
// PURPOSE: mimic gauss function tocart: Converts from polar to
// cartesian coordinates
// ------------------------------------------------------------
// INPUT:
// * r = (N x k) real matrix, radius
// * theta = (L x M), (E x E) conformable with r, angle in
//   radians
// ------------------------------------------------------------
// OUTPUT:
// * xy = max(N,L) by max(K,M) complex matrix containing the X
//   coordinate in the real part and the Y coordinate in the
//   imaginary part
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[r,theta]=resize(r,theta)
xy=r .* (cos(theta)+%i*sin(theta))
 
endfunction
