function [bcpf,bctf] = enfvc(bcp,bct,x)
 
// PURPOSE: eliminates peaks or troughs at both ends which are
// lower or higher than values closer to end
//----------------------------------------------------------------
// INPUT:
// * bcp = vector of peak indexes
// * bct = vecto of trough indexes
// * x   = original time series
//----------------------------------------------------------------
// OUTPUT:
// * bcpf = new vector of peak indexes
// * bctf = new vector of trough indexes
//----------------------------------------------------------------
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Adapted from Gauss proprams of M. Watson & D. Harding by Julien Matheron
// Banque de France, centre de recherche, Sept. 2002
 
nv = 0;
if isempty(bcp)|isempty(bct) then
   bctf = [];
   bcpf = [];
   return
end
 
check = 1;
while check == 1
   if isempty(bct)|isempty(bcp) then
      bctf = [];
      bcpf = [];
      return
   end
 
   check_s = 0;
   check_f = 0;
   chkp = 0;
   chkt = 0;
   m = min(min(bcp),min(bct));
 
   if m == min(bcp) then // first TP is a peak
      s = zeros(size(bcp,1),1);
      d1=bcp(1,1);
      if x(1,1)>x(d1,1) then
         s(1,1) = 1;
         nv = 1;
	 bcp = bcp(s==0)		
         chkp = 1;
      else
         ckkp = 0;
      end
 
   else // first TP is a trough
      s = zeros(size(bct,1),1);
      d1=bct(1,1);
      if x(1,1)<x(d1,1) then
         s(1,1)=1;
         nv = 1;
         bct = bct(s==0)
         chkt = 1;
      else
         chkt = 0;
      end
   end
 
   check_s = (chkp|chkt);
   chkp = 0;
   chkt = 0;
   m = max(max(bcp),max(bct));
   if m == max(bcp) then
      s=zeros(size(bcp,1),1);
      d1 = bcp(size(bcp,1),1);
      if x(size(x,1),1)>x(d1,1) then
         s(size(bcp,1),1)=1;
         nv = 1;
	 			 bcp = bcp(s==0)
         chkp = 1;
      else
         chkp = 0;
      end
 
   else
      if isempty(bct) then
         chkt = 1;
      else
         s = zeros(size(bct,1),1);
         d1=bct(size(bct,1),1);
         if x(size(x,1),1)<x(d1,1) then
            s(size(bct,1),1)=1;
            nv = 1;
            bct = bct(s==0)		
            chkt=1;
         else
            chkt = 0;
         end
      end
   end
   check_f = (chkp|chkt);
   if isempty(bct)|isempty(bcp) then
      bctf = [];
      bcpf = [];
      return
   else
      check = (check_s|check_f);
   end
end
 
if nv>0 then
   [bcpf,bctf] = alter2(bcp,bct,x);
   if isempty(bctf)|isempty(bcpf) then
      bctf = [];
      bcpf = [];
      return
   end
else
   bcpf = bcp;
   bctf = bct ;
end
 
endfunction
