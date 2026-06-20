function [xd,removed]=test_add(xd,thresh)
 
// PURPOSE: tests if the multicolinearity of the columns and
// remove the last column if it is greater than a threshold
// ------------------------------------------------------------
// INPUT:
// * xd = a (n x k) real matrix
// * thresh = a positive scalar
// ------------------------------------------------------------
// OUPTUT:
// * xd = a (n x k) or (n x k-1) real matrix
// * removed = a boolean indicating if the last column has been
//   removed or notr
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
 
 
nx=size(xd,2)
[u,d,v] = svd(xd,'e');
lamda = diag(d(1:nx,1:nx));
removed=%f
 
if (lamda(1)/lamda($))^2 > thresh then
   xd(:,$)=[]
   removed=%t
end
endfunction
