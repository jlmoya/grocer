function [rvar]=VAR(grocer_p,varargin)
 
// PURPOSE: performs vector autogressive estimation
// ------------------------------------------------------------
// INPUT:
// * grocer_p = the lag length
// * varargin = arguments which can be:
//   . 'endo=[var1 var2 ... varn]' with vari: the ith
//     endogenous variable in the var
//   . 'exo=[var1 var2 ... varn]' with vari: the ith
//     exogenous variable in the var
//   . the string 'nocte' if the user doesn't want a constant
//     in the model
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . 'dropna' if the user wants to remove the NA values
//     from the data
// ------------------------------------------------------------
// OUTPUT:
// rvar = a results tlist with:
//   . rvar('meth')  = 'var'
//   . rvar('yall')  = y data vector lagged data included
//   . rvar('y')     = y data vector used in the rhs parts of
//                     the VAR
//   . rvar('x')     = x data matrix
//   . rvar('nobs')  = # observations
//   . rvar('nvar')  = # exogenous variables
//   . rvar('neqs')  = # endogenous variables
//   . rvar('resid') = residuals, with rvar('resid')(:,i):
//                     residuals for equation # i
//   . rvar('beta')  = bhat, with rvar('beta')(:,i):
//                     coefficients for equation # i
//   . rvar('rsqr')  = rsquared, with rvar('rsqr')(i) :
//                     rsquared for equation # i
//   . rvar('overallf') = F-stat for the nullity of
//                     coefficients other than the constant
//                     with: rvar('f')(i): F-stat for equation
//                     # i
//   . rvar('pvaluef') = their significance level with:
//                     rvar('pvaluef')(i): significance level
//                     for equation # i
//   . rvar('rbar')  = rbar-squared
//   . rvar('sigu')  = sums of squared residuals with
//                     rvar('sigu')(:,i): sum of squared
//                     residuals for equation # i
//   . rvar('ser')   = standard errors of the regression with
//                    rvar('ser')(i): standard error for
//                    equation # i
//   . rvar('tstat') = t-stats, with rvar('tstat')(:,i):
//                     t-stat for equation # i
//   . rvar('pvalue')= pvalue of the betas, with
//                      rvar('pvalue')(:,i): p-value for
//                      equation # i
//   . rvar('dw')    = Durbin-Watson Statistic, with:
//                    rvar('dw')(i): DW for equation # i
//   . rvar('condindex') = multicolinearity cond index, with
//                         rvar('condindex')(i): cond index for
//                         equation # i
//   . rvar('boxq') = Box Q-stat, with rvar('boxq')(i):
//                    Box Q-stat for equation # i
//   . rvar('sigma') = (neqs x neqs) var-covar matrix of the
//                     regression
//   . rvar('aic') = Akaïke information criterion
//   . rvar('bic') = Schwartz information criterion
//   . rvar('hq') = Hannan-Quinn information criterion
//   . rvar('xpxi') = inv(X'X)
//   . rvar('vcovar') = variance matrix of the vector of all
//     coefficents
//   . rvar('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rvar('nx') = # of x variables
//   . rvar('namey') = name of the y variable
//   . rvar('namex') = name of the x variables (if any)
//   . rvar('dropna') = boolean indicating if NAs had
//     been dropped
//   . rvar('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rvar('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// Copyright Eric Dubois 2002-2013
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_dropna=%f
grocer_prt=%t
grocer_flagexo=%f
 
grocer_nargin=length(varargin)
grocer_nocte = [] // automatically include a constant term as an exogenous variable
for grocer_i=1:grocer_nargin
 
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_st=strsubst(varargin(grocer_i),' ','')
 
      if part(grocer_st,1:5) == 'endo=' then
         grocer_endo=str2vec(grocer_st)
 
      elseif part(grocer_st,1:4) == 'exo=' then
        grocer_exo=str2vec(grocer_st)
        grocer_flagexo=%t
 
      elseif grocer_st == 'noprint' then
         grocer_prt=%f
 
      elseif grocer_st == 'nocte' then
         grocer_nocte = 'nocte'
 
      elseif grocer_st == 'dropna' then
         grocer_dropna = %t
      end
 
   else
      error(typeof(varargin(grocer_i))+': not a valid type in var')
   end
 
end
 
if exists('grocer_boundsvar') then
   if size(grocer_boundsvar,1) > 2 then
      error('you cannot use discountinous bounds in VAR')
   end
end
 
// explodes the list of the arguments into the corresponding
// variables, their names, and, if necessary creates the bounds
if grocer_flagexo then
 
   [y,namey,x,namex,prests,boundsvarb,nonna]=explouniv(grocer_endo,grocer_exo,[],['endogenous' 'exogenous'],%t,grocer_dropna,%f,[grocer_p;0])
   // explodes the list of the arguments into the corresponding
   // variables, their names, and, if necessary updates the bounds
   if grocer_nocte ~='nocte' then
      namex=[namex ; 'const']
   end
   rvar=var1(y,grocer_p,x,grocer_nocte)
   rvar(1)($+1)='namey'
   rvar($+1)=namey
   rvar(1)($+1)='namex'
   rvar('namex')=namex
 
else
 
   [y,namey,prests,boundsvarb,nonna]=explone(grocer_endo,[],'endogenous',%t,grocer_dropna,%f,grocer_p)
   rvar=var1(y,grocer_p,[],grocer_nocte)
   rvar(1)($+1)='namey'
   rvar($+1)=namey
   namex=[]
   if grocer_nocte ~='nocte' then
      namex=[namex ; 'const']
   end
   rvar(1)($+1)='namex'
   rvar('namex')=namex
 
end
 
rvar(1)($+1)='prests'
rvar($+1)=prests
rvar(1)($+1) = 'dropna'
rvar('dropna')=grocer_dropna
 
if prests then
   rvar(1)($+1)='bounds'
   rvar($+1)=boundsvarb
end
 
if grocer_dropna then
   rvar(1)($+1)='nonna'
   rvar('nonna')=nonna
end
 
if grocer_prt then
   prtvar(rvar,%io(2))
end
 
endfunction
