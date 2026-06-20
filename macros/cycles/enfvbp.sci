function [bcpf,bctf] = enfvbp(bcp,bct,x,e)
 
// PURPOSE: eliminates turns within e quarters of begining
// or end of the series x (e=6 months if monthly data, e=2
// if quarterly series)
//----------------------------------------------------------------
// INPUT:
// . bcp = vector of peak indexes
// . bct = vecto of trough indexes
// . x   = original time series
//----------------------------------------------------------------
// OUTPUT:
// . bcpf = new vector of peak indexes
// . bctf = new vector of trough indexes
//----------------------------------------------------------------
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Adapted from Gauss proprams of M. Watson & D. Harding by Julien Matheron
// Banque de France, centre de recherche, Sept. 2002
 
if isempty(bcp)|isempty(bct) then
   bctf = [];
   bcpf = [];
   return
end
 
s = zeros(size(bcp,1),1);
if bcp(1,1)<=e then
   s(1,1) = 1;
end
if bcp(size(bcp,1),1)>size(x,1)-e then
   s(size(bcp,1),1) = 1;
end
 
bcp = bcp(s==0);
 
s = zeros(size(bct,1),1);
if bct(1,1)<=e then
   s(1,1) = 1;
end
 
if bct(size(bct,1),1)>size(x,1)-e then
   s(size(bct,1),1) = 1;
end
 
bct =bct(s==0)
 
bcpf = bcp;
bctf = bct;
endfunction
