function [y,res]=chowlin_d()
 
// PURPOSE: demo of chowlin()
//          Temporal disaggregation with indicators.
//      Chow-Lin method
//---------------------------------------------------
//
// Low-frequency data: Spain's Exports of Goods. 1995 prices
//
 
 
global GROCERDIR;
 
load(GROCERDIR+'\data\xesp.dat')
 
[y,res] = chowlin('Y','x','ta=-1','typemin=wls');
pltseries(y,'styleg=2','window=1')
 
[y,res] = chowlin('Y','x','ta=-1','typemin=llike');
pltseries(y,'styleg=2','window=2')
endfunction
