function [bcpf,bctf] = turnhp(x,k,M,e,m)
 
// PURPOSE: performs harding-pagan datation methods
//-------------------------------------------------------
// INPUT:
// * x  = vector
// * k  = # to determine the local min or max
// * M  = minimal duration Peaks-Peaks or Trought-Trought
// * e	= min # of periods separating a turn form borders
// * m	= minimal phase
//--------------------------------------------------------
// OUPUT:
// * bcpf = new vector of peak indexes
// * bctf = new vector of trough indexes
//--------------------------------------------------------
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Adapted from Gauss proprams of M. Watson & D. Harding by Julien Matheron
// Banque de France, centre de recherche, Sept. 2002
 
[bcp,bct] = turnpoints(x,k) ;
[bcpf,bctf] = censor(bcp,bct,x,M,e,m) ;
endfunction
