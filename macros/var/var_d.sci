function [results,resirf]=var_d()
// PURPOSE: An example of using var to estimate a
//           vector autoregressive model,taken from
//         "Introduction to multiple time series analysis"
//         by Helmut Lütkepohl (chapter 3)
//
 
//importexcel('c:/scilab-2.6/scied/grocer/varsci/lutk1.csv',";",'c:/scilab2.5/scied/varsci/lutk1.dat')
 
global GROCERDIR;
 
load(GROCERDIR+'/data/lutk1.dat')
 
bounds('1960q4','1978q4')
results=VAR(2,'endo=delts(log(rfa_inv));delts(log(rfa_inc));delts(log(rfa_cons))')
// a calculation with orthogonized residuals and asymptotic confidence band
[resirf]=irf(results,10,'mres=chol1','meth=asym')
pltirf1(resirf)
write(%io(2),'Press a key to continue','(a)')	;
halt();
 
// a calculation with original resiudals and Monte-Carlo confidence band
[resirf]=irf(results,10,'mres=original','meth=bootstrap','niter=1000')
pltirf1(resirf)
write(%io(2),'Press a key to continue','(a)')	;
halt();
 
// a calculation with 1-sigma orthogonalized residuals and Monte-Carlo confidence band
[resirf]=irf(results,10,'mres=chol2','meth=bootstrap','niter=1000')
pltirf1(resirf)
 
endfunction
