function [res]=add_r2(res,sigu,ym,nobs,nvar)
 
// PURPOSE: add R2 to a results tlist
// ------------------------------------------------------------
// INPUT:
// * res = the results tlist
// * sigu  = sum of squared residuals
// * ym = demeaned y
// * nobs = # of observations
// * nvar = # of variables
// ------------------------------------------------------------
// OUTPUT:
// * res = the results tlist
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
df=nobs-nvar
rsqr2 = ym'*ym;
// r-squared
res(1)($+1)='rsqr'
rsqr=1-sigu/rsqr2
res('rsqr') =rsqr
nobsm1=nobs-1
nvarm1=nvar-1
res(1)($+1)='rbar'
res('rbar') = 1-sigu/df/rsqr2*nobsm1
// rbar-squared
if rsqr ~= 1 then
   f=rsqr/(1-rsqr)*df/(nvar-1)
else
   warning('rsqr = 1: your exogenous variables are exactly colinear')
   f=%inf
end
pvaluef=1-cdff("PQ",f,nvarm1,nobs-nvar)
res(1)($+1)='f'
res('f') = f
res(1)($+1)='pvaluef'
res('pvaluef') = pvaluef
endfunction
