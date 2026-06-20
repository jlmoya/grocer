function []=prte4(results,out)
 
// PURPOSE: prints the results of e4 estimates on the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// varma()
// ------------------------------------------------------------
// Copyright (c) Jaime Terceiro, 1997
// Eric Dubois 2003 for the scialb translation and adaptation
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   out=%io(2)
end
 
theta=results('coeff')
labtheta=results('lab')
y=results('y')
fval=results('like')
g=results('grad')
dt=results('std')
corrm=results('cov')
k=results('nvar')
 
write(out,' ');
write(out,'******************** Results from model estimation ********************');
write(out,'Log-likelihood: '+string(fval));
write(out,'Information criteria: AIC = '+string(results('AIC'))+', BIC = '+string(results('BIC')))
write(out,' ');
if results('exact') then
   mat2print = ['Parameter' 'Estimate'  'Std. Dev.'       't-test' ; ..
   labtheta string([theta std tstat])]
else
   mat2print = ['Parameter' 'Estimate'  'Appr.Std.Dev.'       't-test' ; ..
   labtheta string([theta std tstat])]
end
 
printmat(mat2print,out)
 
write(out,' ');
if k>1 then
  write(out,'************************* Correlation matrix **************************');
  nbcor=size(corrm,1)
  mat2print=[labtheta emptystr(nbcor,nbcor)]
  for i = 1:nbcor
     mat2print(i,2:i+1)=string(corrm(i,1:i))
  end
  printmat(mat2print,out)
  write(out,' ');
  write(out,'           Condition number = '+ string(cond(corrm)));
  write(out,'Reciprocal condition number = '+ string(rcond(corrm)));
end
write(out,'***********************************************************************');
write(out,' ');
endfunction
