function rd = gmmDtest(ugmm,rgmm,nr,np)
 
// PURPOSE: performs D test of model comparison for
//   efficient GMM as proposed by Newey & West (1987)
// ------------------------------------------------------------
// INPUTS:
// . ugmm = tlist result under unrestricted estimation
// . rgmm = tlist result under restricted estimation
// . nr = number of restrictions
// . np = 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUPUTS: rd a tlist with
// . rd('chistat') = test statisitc
// . rd('pvalue') = pvalue of the test
// . rd('df') = number of restrictions
// ------------------------------------------------------------
// REFERENCE:
//  W.K. Newey & K. D. West (1987), "Hypothesis Testing With
//    Efficient Method of Moments Estimation",
//    International Economic Review, 28(3), 777-787
// ------------------------------------------------------------
// E. Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0);
if nargin < 4 then
   prt=%t;
else
   if np == 'noprint' then
      prt=%f;
   else
      error('argument 4 in gmmDtest should be ''noprint''');
   end
end
 
if nargin ==2 then
  error('Number of parameter restrictions is missing');
end
 
uWtype = ugmm('W type');
rWtype = rgmm('W type');
Wopti = ['I','Z','S','C'];
 
// test optimality of the weighting matrix
if ~or(uWtype == Wopti) then
  error('Weighting matrtix is not optimal in unrestricted estimation');
elseif ~or(rWtype == Wopti) then
  error('Weighting matrtix is not optimal in restricted estimation');
end
 
if uWtype~=rWtype then
  error('Weighting matrtix are not identical in unrestricted and restricted estimation');
end
 
 
// test satisitics
D = ugmm('nobs')^2*(rgmm('f')-ugmm('f'));
pval = 1 - cdfchi("PQ",D,nr);
 
rd = tlist(['results';'method';'Dstat';'pvalue';'df'],'D test',D,pval,nr);
 
if prt then
  out=%io(2)
  write(out,'Efficient GMM D-test of model restriction');
  write(out,'chi2('+string(nr)+')='+string(D));
  write(out,'(p-value            = '+string(pval)+')');
  write(out,' ');
end
 
endfunction
