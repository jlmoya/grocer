function resw=waldchi(R,r,resu,np)
 
// PURPOSE: computes Wald Chi-squared test for linear
// constraints on parameters
// ------------------------------------------------------------
// INPUT:
// * R = a (q x n-beta) matrix of linear constraints
// * r = a (q x 1) vector of linear constraints values
// * resu = a results tlist from an ols(), pfixed() regression
// * np= 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUTPUT:
// resw = a results tlist with:
// - resw('meth')   = 'waldchi'
// - resw('runcons') = results tlist of the unrestricted
//   regression
// - resw('chi') = Wald Chi-squared statistic
// - resw('def') = degrees of freedom of the chi2
// - resw('chi_pvalue') = p-value of the test
// - resw('R') = (q x n-beta) matrix of linear constraints
// - res('r') = q-vector of linear constraints values
// ------------------------------------------------------------
// PRINTS:
// (if the user hase entered 'noprint' as third argument)
// the results of the test and its signifcance level
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux 2012
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 3 then
   prt=%t
else
   if np == 'noprint' then
      prt=%f;
   else
      error('argument 3 in waldchi should be ''noprint''');
   end
end
 
if typeof(resu) ~= 'results' then
  error('waldf requires an ols results tlist as second input');
end
 
nb=size(resu('beta'),'*');
def=size(R,1);
r=r(:);
 
if size(R,1)~=size(r,1) then
  error('R # of lines doesn''t match with that of r');
elseif size(R,2)~=nb
  error('number of coefficents not equal to R # of lines') ;
end
 
[chistat,chi_pvalue,def]=waldchi0(R,r,resu)
 
resw=tlist(['results';'meth';'runcons';'chistat';'chi_df';'chi_pvalue';'R';'r'],...
'waldchi',resu,chistat,def,chi_pvalue,R,r)
 
if prt then
   prtchi(resw)
end
endfunction
