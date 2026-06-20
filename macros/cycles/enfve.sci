function [bcpf,bctf] = enfve(bcp,bct,x,m)
 
// PURPOSE: eliminates all phases with duration less than m
//----------------------------------------------------------------
// INPUT:
// * bcp = vector of peak indexes
// * bct = vecto of trough indexes
// * x   = original time series
// * m   = minimal duration length of a phase
//----------------------------------------------------------------
// OUTPUT:
// * bcpf = new vector of peak indexes
// * bctf = new vector of trough indexes
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
 
 
bcp = [bcp,ones(size(bcp,1),1)];
bct = [bct,zeros(size(bct,1),1)];
anmat = sortc([bcp;bct],1);
nv = 0;
iter = 0;
j=1;
 
while j<=size(anmat,1)-1
   iter = iter+1;
   bcp = [bcp,ones(size(bcp,1),1)];
   bct = [bct,zeros(size(bct,1),1)];
   anmat = sortc([bcp;bct],1);
 
   if j+1>size(anmat,1) then
      break
   end
 
   cind = anmat(j,1);
   nind = anmat(j+1,1);
 
   if nind-cind<m then
      nv = 1;
      s = zeros(size(anmat,1),1);
      s(j+1,1) = 1;
 
      anmat  =anmat(s==0,:)
      bcp = anmat(anmat(:,2)>0,1); 	
      bct = anmat(anmat(:,2)<1,1);
      [bcp,bct] = alter2(bcp,bct,x) ;
 
      if isempty(bcp)|isempty(bct) then
         bctf = [];
         bcpf = [];
         return
      else
         j=j-1;
      end
 
   else
      bcp = bcp(:,1);
      bct = bct(:,1);
   end
 
   j=j+1;
end
 
bcpf = bcp(:,1);
bctf = bct(:,1);
endfunction
