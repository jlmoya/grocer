function [chistat,chiprb,def]=waldchi0(R,r,resu)
 
// PURPOSE: computes Wald chi-test for two regressions
// ------------------------------------------------------------
// INPUT:
// * R (q x n-beta) matrix of linear constraints
// * r = q-vector of linear constraints values
// * resu = results tlist from ols(), pfixed() regression
// ------------------------------------------------------------
// OUTPUT:
// - chistat = Wald Chi-squared statistic
// - chi_pvalue = p-value of the test
// - def = degrees of freedom
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux 2012
//  http://grocer.toolbox.free.fr
 
 
nb=size(resu('beta'),'*');
def=size(R,1);
r=r(:);
 
if size(R,1)~=size(r,1) then
  error('R # of lines doesn''t match with that of r');
elseif size(R,2)~=nb
  error('number of coefficents not equal to R # of lines') ;
end
 
V=resu('vcovar');
bet=resu('beta');
lc=R*bet-r;
 
chistat= lc'*inv(R*V*R')*lc;
chiprb=1-cdfchi("PQ",chistat,def);
 
endfunction
