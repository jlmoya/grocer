function [resulbp]=bpagan(resulols,varargin)
 
// PURPOSE: Breusch and Pagan heteroskedasticity test
// ------------------------------------------------------------
// REFERENCES: Breusch and Pagan, Econometrica 1979
// ------------------------------------------------------------
// INPUT:
// * resulols = results tlist from a first stage estimation
// * varargin = arguments of the second stage regression, which
// can be:
//   . a time series
//   . a real (nxp) vector
//   . a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
// ------------------------------------------------------------
// OUPTUT:
// resulbp = a results tlist with:
// - resultbp('meth')   = 'bpagan'
// - resultbp('resul1st') = results tlist of the first stage
//   regression
// - resultbp('u2') = sum of square residuals from the first
//   stage regression
// - resultbp('namex2') = names of the exogenous variables in
//   the second stage regression
// - resultbp('x2') = vector of the exogenous variables in the
//   second stage regression
// - resultbp('f') = Breush-Pagan LM-statistic (Fisher form)
// - resultbp('dfnum') = degrees of freedom of the numerator
// - resultbp('dfden') = degrees of freedom of the denominator
// - resultbp('f_pvalue) = p-value of the test
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatia-econometrics.com
 
 
nvar=resulols('nvar')
u2=resulols('resid').^2
// take the bounds of the first stage regression
// as the ones of the Goldfeld-Quandt regression
if resulols('prests') then
   boundsvar=resulols('bounds')
end
 
// separate from the list of variable arguments the list of
// exogenous variables and 'noprint' if the user has given this
// argument
 
prt=%t
prtreg=%f
nargin=length(varargin)
for i=nargin:-1:1
   if typeof(varargin(i)) == 'string' then
      if varargin(i) == 'noprint' then
         varargin(i)=null()
         prt=%f
      elseif varargin(i) == 'prtreg' then
         varargin(i)=null()
         prtreg=%t
      end
   end
end
 
lx=varargin
// explode the list of the arguments into the corresponding
// variable, its name, and, if necessary updates the bounds
[x2,namexos2,boundsvarb]=explol(lx,[],'exogenous')
 
[nobs,nvar2] = size(x2)
nobs2 = size(u2,1);
if nobs~=nobs2 then
   write(%io(2),'nobs of the squared residuals ='+string(nobs2),'(a)')
   write(%io(2),'nobs of the exogenous variables='+string(nobs),'(a)')
   error('residuals and exogenous variable must have same # obs in bpagan');
end
 
// determine if there is a constant in the exogenous variables
prescte=%f
i=1
while (i <= nvar2) & ~prescte then
   // if all values are equal to the first one then,
   // the variable is constant
   prescte=and(x2(:,i) == x2(1,i))
   i=i+1
end
 
// if it is absent, add a constant to the regression
if ~prescte then
   nvar2=nvar2+1
   x2 = [x2 ones(nobs,1)]
   namexos2 = [namexos2 ; 'cte']
   varargin($+1)='cte'
end
 
[f,f_pvalue,nvar2,r2]=bpagan0(u2,x2,nvar)
dfd=nvar2-1
dfn=nobs-nvar-nvar2
resulbp=tlist(['results';'meth';'resul1st';'u2';'namex2';'x2';'f';...
'dfnum';'dfden';'f_pvalue'],...
'bpagan','resulols',u2,namexos2,x2,...
f,dfd,dfn,f_pvalue)
 
if prt then
   if prtreg then
      write(%io(2),'Breusch and Pagan second stage regression','(a)')
      ols('u2',varargin(:))
   end
   prtfish(resulbp)
end
endfunction
