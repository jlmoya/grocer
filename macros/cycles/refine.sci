function [bcpn,bctn] = refine(bcp,bct,x,n);
 
// PRUPOSE: Refine turning point dates
//  The original dates are bcp (peaks) and bct (troughs)
//  These are refined using the series x. The new dates are
//  those highest (for peaks) or lowest (for troughs) which are
//  within n periods of the old dates.
//---------------------------------------------------------
// INPUTS:
// * bcp = vector of peak indexes
// * bct = vector of trough indexes
// * x   = original time series
// * n   =  interval of refinment
// -------------------------------------------------------------
// OUTPUTS :
// * bcpf : new vector of peak indexes
// * bctf : new vector of trough indexes
// -------------------------------------------------------------
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss proprams of M. Watson
 
// Pad X with n extra points at beginning and end
xpad=[.99999*x(1,1)*ones(n,1) ; x ; .99999*x(rows(x),1)*ones(n,1)];
 
// For each peak date find highest ñ n months
bcpn=bcp;
for i =1:rows(bcp)
   d=bcp(i,1);
   t=seqa(-n,1,2*n+1);
   b=sortc([xpad(n+d-n:n+d+n,1) t],1);
// Check for Ties -- Choose latest of the ties
   b= b(b(:,1)==b(rows(b),1),:)
//selif(b,b(.,1).==b(rows(b),1));
   bcpn(i,1)=d+max(b(:,2),'r')';
 
end	
 
// For each trough date find lowest ñ n months
bctn=bct;
for i =1:rows(bct)
   d=bct(i,1);
   t=seqa(-n,1,2*n+1);
   b=sortc([xpad(n+d-n:n+d+n,1) t],1);
 
// Check for Ties -- Choose latest of the ties
   b=b(b(:,1)==b(1,1),:);	
//b=selif(b,b[.,1].==b[1,1]);
   bctn(i,1)=d+max(b(:,2),'r')';
 
end;
 
// Make Sure Dates Alternate
[bcpn,bctn]=alter2(bcpn,bctn,x);
//[bcpn,bctn]=alter1(bcpn,bctn,x);
//[bcpn,bctn]=alter2(bcpn,bctn,x);
endfunction
