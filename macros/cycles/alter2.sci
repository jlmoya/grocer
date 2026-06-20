function [bcpf,bctf] = alter2(bcp,bct,x)
 
// PURPOSE: Makes sure that peaks and troughs alternate
//----------------------------------------------------------------
// INPUT:
// * bcp = indexes of peaks
// * bct = indexes of troughs
// * x = original signal
//----------------------------------------------------------------
// OUTPUT:
// * bcpf = new peaks indexes
// * bctf = new troughs indexes
//----------------------------------------------------------------
//
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Adapted from Gauss proprams of M. Watson & D. Harding by Julien Matheron
// Banque de France, centre de recherche, Sept. 2002
 
if isempty(bct) | isempty(bcp) then
   bctf = [] ;
   bcpf = [];
   return
end
 
bcp = [bcp,ones(size(bcp,1),1)];
bct = [bct,zeros(size(bct,1),1)];
anmat =sortc([bcp;bct],1);
nv = 0;
j=1;
 
while j<=size(anmat,1)-1
   cval = anmat(j,2);
   nval = anmat(j+1,2);
   if nval==cval then
 
      if cval==1 then
         s=zeros(size(anmat,1),1);
         d1 = anmat(j,1);
         d2 = anmat(j+1,1);
         if x(d1,1)>=x(d2,1) then
            s(j+1,1)=1;
         else
            s(j,1)=1;
         end
         anmat =anmat(s==0,:);
 
         nv=1;
         j=j-1;
      else
         s=zeros(size(anmat,1),1);
         d1 = anmat(j,1);
         d2 = anmat(j+1,1);
         if x(d1,1)>=x(d2,1) then
            s(j,1)=1;
         else
            s(j+1,1)=1;
         end
         anmat=anmat(s==0,:);
 
         nv=1;
         j=j-1;
      end
   end
   j=j+1;
end
	
bcpf = anmat(anmat(:,2)>0,1); 	
bctf = anmat(anmat(:,2)<1,1);
 
 
endfunction
