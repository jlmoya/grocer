function [crit,pval] = critecm(tstat,k,d,T,h)
 
// PURPOSE: Computes critical values and p-values
//  using the response surfaces in Ericsson and MacKinnon (1999)
//  as implemented in the program ECMtest.xls (version 1.0)
// ------------------------------------------------------------
// REFERENCE: N. R. Ericsson & J. G. MacKinnon (2002),
// "Distribution of error correction test for cointegration"
// Econometrics Journal, 5, 285-318
// ------------------------------------------------------------
// INPUT:
// * tstat= t-value on the error correction term
// * k = size of the cointegrationg vector
// * d = type of deterministic variables
//   . d = -1, no deterministic part
//   . d = 0, for constant term
//   . d = 1, for constant plus time-trend
//   . d = 2, for costant plus quadratic time-trend
// * T = Estimation sample size
// * h = total number of regressors in the ECM
// ------------------------------------------------------------
// OUTPUT:
// * crit = critical value of the test
// * pval = p-value of the test
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux 2007
// http://grocer.toolbox.free.fr/grocer.html
// based on ECCMtest.xls provided by MacKinnon
 
global GROCERDIR;
 
if k>12 then
  error('critical values are only available up through 12 variables in the coinetgrating relation');
end
 
// Number of deterministic variables
// (nil, constant, linear trend, quadratic trend)
select d
case -1 then
  sd = 'nc';
  nd =0;
case 0 then
  sd = 'c';
  nd =1;
case 1 then
  sd ='ct';
  nd =2;
case 2 then
  sd ='ctt';
  nd =3;
else
  error('Unknown type of determinisitc part');
end
 
 
load(GROCERDIR+'\data\dbecm\ecm_index_Ta.dat');
execstr('load('''+GROCERDIR+'\data\dbecm\ecm'+string(k)+sd+'.dat'')');
 
 
// search for the index for the type of response surface
// to adjust the sample size
ita=find((index_p==nd)&(index_k==k))
if or(index_Ta(ita)==[6,7]) then
  Tadj= T-h;
elseif or(index_Ta(ita)==[4,5])
  Tadj= T-h+k;
end
 
// compute critical values
FS = theta_0 + theta_1/Tadj + theta_2/Tadj^2 + theta_3/Tadj^3 + theta_4/Tadj^4;
lambda = (FS(2:$-1)-tstat)./(FS(2:$-1)-FS(3:$));
tentp = (ones(size(lambda,1),1)-lambda).*p(2:$-1)+lambda.*p(3:$);
 
// find the approximate pvalue
if FS(2)>tstat then
  pval = '< 0.000';
  crit = '< '+string(FS(2));
elseif tstat>FS($) then
  pval = '> 0.9999';
  crit = '> '+string(FS($));
else
  fi = find((lambda>=0)&(lambda<=1));
  pval = tentp(fi);
  crit = FS(fi+2);
end
endfunction
 
 
 
 
 
 
 
 
