function rd = gmmMomtRestr(ugmm,rgmm,np)
 
// PURPOSE: performs test of moment restriction
//    for efficient GMM
// ------------------------------------------------------------
// INPUTS:
// . ugmm = tlist result for unrestricted estimation
// . rgmm = tlist result for restricted estimation
// . np = 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUPUTS: rd a tlist with:
// . rd('chistat') = test statisitc
// . rd('pvalue') = pvalue of the test
// . rd('df') = number of restrictions
// ------------------------------------------------------------
// E. Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0);
if nargin == 2 then
   prt=%t;
else
   if np == 'noprint' then
      prt=%f;
   else
      error('argument 3 in aragan should be ''noprint''');
   end
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
 
// degree of freedom
nub = ugmm('north');
nrb = rgmm('north');
df = nub-nrb;
 
if df < 0 then
  error('the restricted model as more parameters than the unrestricted model');
end
 
 
// test satisitics
chi = ugmm('nobs')*(rgmm('f')-ugmm('f'));
pval = 1 - cdfchi("PQ",chi,df);
 
rd = tlist(['results';'method';'Dstat';'pvalue';'df'],'mom',chi,pval,df);
 
if prt then
  out=%io(2)
  write(out,'Efficient GMM test of moment restriction');
  write(out,'chi2('+string(df)+')='+string(chi));
  write(out,'(p-value            = '+string(pval)+')');
  write(out,' ')
end
 
endfunction
 
 
 
 
 
 
