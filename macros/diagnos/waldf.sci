function [resulwa]=waldf(resultr,resultu,np)
 
// PURPOSE: computes Wald F-test for two regressions
// ------------------------------------------------------------
// INPUT:
// * resultr = results tlist from ols() restricted regression
// * resultu = results tlist from ols() unrestricted regression
// * np= 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUTPUT:
// resulbp = a results tlist with:
// - resultbp('meth')   = 'waldf'
// - resultbp('runcons') = results tlist of the unrestricted
//   regression
// - resultbp('rcons') = results tlist of the restricted
//   regression
// - resultbp('f') = Wald F-statistic
// - resultbp('dfnum') = degrees of freedom of the numerator
// - resultbp('dfden') = degrees of freedom of the denominator
// - resultbp('f_pvalue') = p-value of the test
// ------------------------------------------------------------
// PRINTS:
// (if the user hase entered 'noprint' as third argument)
// the results of the test and its signifcance level
// ------------------------------------------------------------
// NOTE:  large fstat => reject the restrictions as
//            inconsistent with the data
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
[nargout,nargin] = argn(0)
if nargin == 2 then
   prt=%t
else
   if np == 'noprint' then
      prt=%f
   else
      error('argument 3 in waldf should be ''noprint''')
   end
end
 
if typeof(resultu) ~= 'results' then
  error('waldf requires an ols results tlist as second input');
end
nu = resultu('nobs');
ku = resultu('nvar');
 
if typeof(resultr) == 'results' then
   nr = resultr('nobs');
   if resultr('meth') == 'constrained ols'
      resultr('nvar')=resultr('nvar')-size(resultr('R'),1)
   end
   kr = resultr('nvar');
elseif resultr == [] then
   nr=nu
   kr=0
else
   error('waldf requires an ols results tlist or [] as first input');
end
 
 
if nu~=nr then
  error('waldf: the # of obs in the results tlists are different');
end
if (ku-kr)<0 then
  // flag reversed input arguments
  error('waldf: negative dof, check for reversed input arguments');
end
 
[fstat,f_pvalue,dfnum,dfden]=waldf0(resultr,resultu)
 
resulwa=tlist(['results';'meth';'runcons';'rcons';'f';...
'dfnum';'dfden';'f_pvalue'],...
'waldf',resultu,resultr,fstat,dfnum,dfden,f_pvalue)
 
if prt then
   prtfish(resulwa)
end
endfunction
