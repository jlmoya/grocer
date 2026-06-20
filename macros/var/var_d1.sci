function [results]=var_d1()
// PURPOSE: An example of using var to estimate a
//           vector autoregressive model,taken from
//         "Introduction to multiple time series analysis"
//         by Helmut Lütkepohl (chapter 3)
//
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/lutk1.dat')
 
bounds('1960q4','1978q4')
results=VAR(2,'endo=delts(log(rfa_inv));delts(log(rfa_inc));delts(log(rfa_cons))')
 
endfunction
