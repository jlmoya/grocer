function [y,res]=fernandez_d()
 
// PURPOSE: demo of fernandez()
//          Temporal disaggregation with indicators.
//      Fernandez method
//---------------------------------------------------
// USAGE: fernandez_d
//---------------------------------------------------
//
 
global GROCERDIR;
 
load(GROCERDIR+'\data\xesp.dat')
 
[y,res] = fernandez(Y,x,'ta=-1');
 
endfunction
