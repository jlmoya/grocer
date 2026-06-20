function matout=reshape_gauss(matin,n,m)
 
// PURPOSE: function that mimics gauss function reshape
// ------------------------------------------------------------
// INPUT:
// * matin = a (pxq) matrix
// * n = # of rows of the destination matrix
// * m = # of cols of the destination matrix
// ------------------------------------------------------------
// OUPTUT:
// * matout = the (nxm) destinaion matrix
// ------------------------------------------------------------
// NOTE: there is in grocer a function reshape that does not
//   have the same purpose: similar to Troll portable (instead
//   of gauss) function reshape, it transforms a vector into a
//   ts
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
sizein=size(matin,1)*size(matin,2)
vecin=matrix(matin,sizein,1)
sizeout=n*m
if sizein > sizeout then
   matout= matrix(vecin(1:sizeout),n,m)'
else
   nrepet=floor(sizeout/sizein)
   matout=matrix([ones(nrepet,1) .*. vecin ; ...
   vecin(1:sizeout-nrepet*sizein)],m,n)'
end
 
endfunction
 
