function [resulch]=predfailin(resulols,n1)
 
// PURPOSE: Chow "predictive failure" test
// ------------------------------------------------------------
// INPUT:
// * resulols = a results tlist from a first stage estimation
// * n1 = # of observations of the sub-period
// ------------------------------------------------------------
// OUPTUT:
// resulch = a results tlist with:
//   . resulch('meth') = predfail
//   . resulch('rols') = the tlist results from first stage
//     estimation
//   . resulch('fstat') = value of the test statistic
//   . resulch('f_pvalue') = its p-value
//   . resulch('dfnum') = # dof of the numerator
//   . resulch('dfden') = # dof of the denominator
//   . resulch('cut') = date (if there is a ts in the
//                           regression) or
//                      index of the observation (if there is
//                          no ts in the   regression)
//                      of the break
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 3 then
   if np == 'noprint' then
      prt=%f
   else
      error('argument 3 in chwotest should be ''noprint''')
   end
else
   prt=%t
   if nargin == 1 then
      n1=floor(resulols('nobs')/2)
   end
end
 
if resulols('prests') then
   begdat=resulols('bounds')(1)
   dat1=num2date(date2num(begdat)+n1-1,date2fq(begdat))
else
   dat1 = string(n1)
end
 
[fstat,f_pvalue,dfnum,dfden]=predfailin0(resulols,n1)
resulch=tlist(['results';'meth';'rols';'f';'dfnum';...
'dfden';'f_pvalue';'cut'],..
'predfailin',resulols,fstat,dfnum,dfden,...
f_pvalue,dat1)
 
if prt then
   prtfish(resulch)
end
endfunction
