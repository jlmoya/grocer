function f = gmmLsFunc(b,gmmopt,Y,X,Z,W)
 
// PURPOSE: Evaluate least squares function m(b)''Wm(b) at b
// -------------------------------------------------------------
// INPUTS:
// . b     = parameter vector fed to func
// . gmmopt = gmm options tlist
// . Y = "dependent" variables
// . X = "independent" variables
// . Z = Instruments (can be same as X)
// . W = matrix of weights
// -------------------------------------------------------------
// OUTPUTS:
// . f = function value evaluated at b
// -------------------------------------------------------------
// VERSION: 1.1.1 (1/24/99)
// written by:
// Mike Cliff,  Purdue Finance   mcliff@mgmt.purdue.edu
// CREATED:  12/10/98
// UPDATED:  1/24/99 (1.1)
//           9/23/00 (1.1.1 fcnchk)
// Translated to scilab and modified by E. Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
fmomt = gmmopt('momt');
execstr('m='+fmomt+'(b,gmmopt,Y,X,Z)');
f = m'*W*m;
endfunction
