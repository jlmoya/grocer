function G = gmmLsGrad(b,gmmopt,Y,X,Z,W)
 
// PURPOSE: Evaluate 2M(b)'W m(b) gradients of objective function
// -------------------------------------------------------------
// INPUTS:
// . b = parameter vector fed to func
// . gmmopt = gmm options tlist
// . Y = "dependent" variables
// . X = "independent" variables
// . Z = Instruments (can be same as X)
// . W = matrix of weights
// -------------------------------------------------------------
// OUTPUTS:
// . G = gradients evaluated at b
// -------------------------------------------------------------
// VERSION: 1.2.1 (9/23/00)
// written by:
// Mike Cliff,  Purdue Finance,   mcliff@mgmt.purdue.edu
// CREATED:  12/10/98
// UPDATED:  1/24/99
//           7/21/00 (1.2   Added 2* back into G)
//           9/23/00 (1.2.1 fcnchk)
// Translated to scilab and modified by E. Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
 
fmomt = gmmopt('momt');
fjake = gmmopt('jake');
execstr('m='+fmomt+'(b,gmmopt,Y,X,Z)');
if gmmopt('jake') ~= 'numz0' then
  execstr('M='+fjake+'(b,gmmopt,Y,X,Z)');
else
  nb = max(size(b));
  north=size(m,1)
  deff('fm = momt(b,fmomt,gmmopt,Y,X,Z)','fm=evstr(fmomt+''(b,gmmopt,Y,X,Z)'')');
  M = numz0(momt,b,nb,zeros(nb,north),sqrt(%eps),fmomt,gmmopt,Y,X,Z);
  M=M'
end
 
G = 2*M'*W*m;
 
endfunction
 
