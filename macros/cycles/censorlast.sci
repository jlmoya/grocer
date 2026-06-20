function [bcpf,bctf] = censorlast(bcp,bct,x,M,e,m)
 
// PURPOSE: enforces censoring rules on business cycle indexes
// ---------------------------------------------------------------
// INPUT:
//  * bcp  = vector of peak indexes
//  * bct  = vecto of trough indexes
//  * x    = original time series
//  * M    = minimal duration P-P or T-T
//  * e    = min # of periods separating a turn form borders
//  * m    = minimal phase
// ---------------------------------------------------------------
// OUTPUT:
//  * bcpf = new vector of peak indexes
//  * bctf = new vector of trough indexes
// ---------------------------------------------------------------
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Adapted from Gauss proprams of M. Watson & D. Harding by Julien Matheron
// Banque de France, centre de recherche, Sept. 2002
 
 
[bcp2,bct2] = alter2(bcp,bct,x);  	// forces peaks and troughs to alternate
[bcp3,bct3] = alter1(bcp2,bct2,x); // troughs < peaks
[bcp5,bct5] = alter2(bcp3,bct3,x); // re-forces peaks and troughs to alternate
lastbcp = bcp5;
lastbct = bct5;
done = 0;
 
while done==0
  [bcp1,bct1] = enf1p(bcp5,bct5,x,M);
  [bcp2,bct2] = enfvbp(bcp1,bct1,x,e);
  [bcp3,bct3] = enfvc(bcp2,bct2,x);
  [bcp4,bct4] = enf1p(bcp3,bct3,x,M);
  [bcp5,bct5] = enfve_2(bcp4,bct4,x,m);
  [bcp5,bct5] = enfvc(bcp5,bct5,x);
  done = (size(bcp5,1)==size(lastbcp,1) ) & ( size(bct5,1)==size(lastbct,1)) ;
  lastbcp = bcp5;
  lastbct = bct5;
end;
 
bcpf = bcp5;
bctf = bct5;
 
 
endfunction
