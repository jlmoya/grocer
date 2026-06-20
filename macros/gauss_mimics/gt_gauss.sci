function y=gt_gauss(l,r)
 
// PURPOSE: mimics gauss operation .>
// ------------------------------------------------------------
// INPUT:
// * a = (N x K) matrix or L-dimensional array where the last
//   two dimensions are (N x K)
// ------------------------------------------------------------
// OUTPUT:
// * b = (K x 1) vector or L-dimensional array where the last
//   two dimensions are K×1
// ------------------------------------------------------------
// NOTE:
// for arrays, the function can probably be made more
// efficient...
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[l,r]=resize(l,r)
y=bool2s(l > r)
 
endfunction
