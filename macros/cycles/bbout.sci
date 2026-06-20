function [xo,nxo] = bbout(x,xsp)
 
// PURPOSE: performs outliers detection and replace by
// values of the spencer curve
//-------------------------------------------------------
// INPUT:
// * x   = vector
// * xsp = its transformation by the spencer curve
//--------------------------------------------------------
// OUPUTS:
// * xo = vector corrected from outliers
//--------------------------------------------------------
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Adapted from Gauss proprams of M. Watson & D. Harding by Julien Matheron
// Banque de France, centre de recherche, Sept. 2002
 
nd = size(x,1) ;
 
d = x - xsp ;
ds = studentize(d) ;
 
dsi = (abs(ds) > 3.5) ;
xo = x;
t = (1:nd)';
 
nxo = []
if sum(dsi)>0 then
   // at least one outlier was found
   nxo = t(dsi) ;
   xo(nxo,1)=xsp(nxo,1)
end
endfunction
