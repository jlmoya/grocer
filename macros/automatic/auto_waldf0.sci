function [fstat,fprb,dfnum,dfden]=auto_waldf0(resultr,resultu)
 
// PURPOSE: computes Wald F-test for two regressions
// ------------------------------------------------------------
// INPUT:
// * resultr = results tlist from ols() restricted regression
// * resultu = results tlist from ols() unrestrcted regression
//   or [] if the user wants to test the signifance of all
//   variables in the regression
// ------------------------------------------------------------
// OUTPUT:
// * fstat = {(essr - essu)/#restrict}/{essu/(nobs-nvar)}
// * fprb  = marginal probability for fstat
// ------------------------------------------------------------
// PRINTS:
// (if the user hase entered 'noprint' as third argument)
// the results of the test and its signifcance level
// ------------------------------------------------------------
// NOTE:  large fstat => reject the restrictions as
//                       inconsistent with the data
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2014
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
 
// recover useful data from the results tlist
nobs = resultu('nobs');
ku = resultu('nvar');
epeu=resultu('sigu')
 
if typeof(resultr) == 'results' then
   kr = resultr('nvar');
   eper = max(real(resultr('sigu')),real(resultu('sigu'))+sqrt(%eps))
else
// resultr is supposed to be []
   kr = 0
   eper=sum(resultu('y').^2)
end
 
dfnum = ku-kr;
if dfnum == 0 then
   fstat=0
   fprb=1
   warning('H0 and Ha are indentical')
else
   // find # of restrictions
   dfden = nobs-ku;
   // find denominator dof
   fstat1 = (eper-epeu)/dfnum;
   // numerator
   fstat2 = epeu/dfden;
   // denominator
   fstat = fstat1/fstat2;
 
   fprb = 1-cdff("PQ",fstat,dfnum,dfden);
end
 
endfunction
