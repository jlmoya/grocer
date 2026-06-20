function [bcpf,bctf] = alter1(bcp,bct,x)
 
// PURPOSE: makes sure that peaks are higher than
// troughs - warning : does not ensure that peaks and
// troughs alternate ; see alter2.sci
// -------------------------------------------------------------
// INPUTS:
// * bcp = vector of peak indexes
// * bct = vecto of trough indexes
// * x = original time series
// -------------------------------------------------------------
// OUTPUTS:
// * bcpf = new vector of peak indexes
// * bctf = new vector of trough indexes
// -------------------------------------------------------------
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Adapted from Gauss proprams of M. Watson & D. Harding by Julien Matheron
// Banque de France, centre de recherche, Sept. 2002
 
 
r = min(size(bcp,1),size(bct,1)) ;
e = zeros(size(bct,1),1);
 
if  isempty(bcp) | isempty(bct) then
   bctf = []; bcpf = [];
   return
end
 
if bcp(1,1) < bct(1,1) then // Peaks are first
   r = min(size(bcp,1),size(bct,1)) ;
   i = 1;
   while i<=r
      if x(bct(i),1)>x(bcp(i),1)
         e(i) = 1;
      end
      i = i+1;
   end
 
else     // Troughs are first
   r = min(size(bcp,1),size(bct,1)-1) ;
   i = 1;
   while i<=r
      if x(bct(i+1),1)>x(bcp(i),1)
         e(i+1) = 1;
      end
      i = i+1;
   end
end
 
if r>size(bct,1) then
   e = e(1:size(bct,1));
end
 
bcpf = bcp(:,1);
bctf = bct(e==0,1)
 
endfunction
