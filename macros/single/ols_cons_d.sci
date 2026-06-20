function [rols]=ols_cons_d()
 
// PURPOSE: a demonstration of the cosntarined ols
// ------------------------------------------------------------
// INPUT:
// nothing
// ------------------------------------------------------------
// OUPTUT:
// * rols = the results tlist of the contarined ordinary least
//   squares
// ------------------------------------------------------------
// Copyright: Eric Dubois 2006
// http://grocer.toolbox.free.fr/grocer.html
 
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
// set the estimation bounds
bounds('1964q3','1989q2')
 
// we estimate hendryericsson model by imposing the constraints on
// delts(lagts(1,lm1)), 'delts(lagts(1,lp))' and 'delts(lagts(1,ly))'
// in order to obtain delts(lagts(1,lm1-ly-lp))
// calling b the vector of coefficents, the constriants are:
// b2=-b3 and b2=-b4
// hence:
// * R= [0 1 1 0 0 0 0 ]
//      [ 0 1 0 1 0 0 0]
// and r = [0]
//         [0]
// as expected, it gives the same results as in hendryericsson!
 
rols=ols_cons('delts(lm1-lp)','delts(lp)','delts(lagts(1,lm1))',...
'delts(lagts(1,lp))','delts(lagts(1,ly))','rnet','lagts(1,lm1-lp-ly)','cte',...
'R=[0 1 1 0 0 0 0 ; 0 1 0 1 0 0 0]','r=[0;0]')
 
endfunction
