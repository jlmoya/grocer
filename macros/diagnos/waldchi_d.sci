function []=waldchi_d()

global GROCERDIR;
load(GROCERDIR+'/data/bdhenderic.dat') ;
 
// set the estimation bounds
bounds('1964q3','1989q2')
 
// we estimate hendryericsson model by imposing the constraints on

rols=ols('delts(lm1-lp)','delts(lp)','delts(lagts(1,lm1))',...
'delts(lagts(1,lp))','delts(lagts(1,ly))','rnet','lagts(1,lm1-lp-ly)','cte');

// calling b the vector of coefficents, the constraints are:
// b2=-b3 and b2=-b4
// hence:
// * R= [0 1 1 0 0 0 0 ]
//      [ 0 1 0 1 0 0 0]
// and r = [0]
//         [0]
R=[0 1 1 0 0 0 0 ; 0 1 0 1 0 0 0];
r=[0;0];
waldchi(R,r,rols);

endfunction


 
