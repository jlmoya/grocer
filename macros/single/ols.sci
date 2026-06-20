function [rols]=ols(grocer_namey0,varargin)
 
// PURPOSE: the most general function performing least-squares
// regression
// ------------------------------------------------------------
// INPUT:
// * grocer_namey0 = a time series, a real (n x 1) vector or a
// string equal to the name of a time series or a (n x 1) real
// vector between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (nxp) vector
//   . a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   . 'dropna' if the user wants to remove the NA values
//     from the data
//   . 'saturate(x)' if the user wants to test breaks with
//     impulse indicator saturation at the size x
//   . 'noprint' if the user does not want to print the
//     estimation results
// ------------------------------------------------------------
// OUTPUT:
// rols = a results tlist with
//   . rols('meth')  = 'ols' or 'saturated ols'
//   . rols('y')     = y data vector
//   . rols('x')     = x data matrix
//   . rols('nobs')  = # observations
//   . rols('nvar')  = # variables
//   . rols('beta')  = bhat
//   . rols('yhat')  = yhat
//   . rols('resid') = residuals
//   . rols('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rols('sige')  = estimated variance of the residuals
//   . rols('sigu')  = sum of squared residuals
//   . rols('ser')  = standard error of the regression
//   . rols('tstat') = t-stats
//   . rols('pvalue') = pvalue of the betas
//   . rols('dw')    = Durbin-Watson Statistic
//   . rols('condindex') = multicolinearity cond index
//   . rols('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rols('llike') = the log-likelihood
//   . rols('aic')= the Akaike information criterion
//   . rols('bic')= the Schwarz information criterion
//   . rols('hq')= the Hannan-Quinn information criterion
//   . rols('rsqr')  = rsquared
//   . rols('rbar')  = rbar-squared
//   . rols('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rols('pvaluef') = its significance level
//   . rols('like') = log-likelihood of the regression
//   . rols('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rols('namey') = name of the y variable
//   . rols('namex') = name of the x variables
//   . rols('dropna') = boolean indicating if NAs have
//		   been dropped
//   . rols('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rols('nonna') = vector indicating position of non-NAs
//   . rols('saturation significance level') = significance
//     level used to keep the dummies
//   . rols('significant dummies') = the remaining dummies
//     after testing
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_dropna=%f
grocer_prt=%t
grocer_nargin=length(varargin)
grocer_saturating=%f
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if grocer_argi == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      elseif part(grocer_argi,1:8) == 'saturate' then
         grocer_saturating=%t
         varargin(grocer_i)=null()
         grocer_ind_leftpar=strindex(grocer_argi,'(')
         if ~isempty(grocer_ind_leftpar) then
            grocer_ind_rightpar=strindex(grocer_argi,')')
            execstr('grocer_alphasatur='+part(grocer_argi,grocer_ind_leftpar(1):grocer_ind_rightpar(1)))
         end
      end
   end
end
 
[y,namey,x,namexos,prests,boundsvarb,nonna]=...
explouniv(grocer_namey0,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
// provides the results from the regression of the vector y
// on the vector x
if grocer_saturating then
    nobs=size(y,2)
    if ~exists('grocer_alphasatur','local') then
       grocer_alphasatur=1/nobs
    end
    [z,dummies]=indicator_saturation1(y,x,grocer_alphasatur)
    x=[x,z]
end
 
rols=ols2(y,x)
 
// saves the names, the bounds if the regression involves ts
rols(1)($+1) = 'prests'
rols(1)($+1) = 'namex'
rols(1)($+1) = 'namey'
rols(1)($+1) = 'dropna'
rols('prests')=prests
rols('namex')=namexos
rols('namey')=namey
rols('dropna')=grocer_dropna
 
if prests then
   rols(1)($+1) = 'bounds'
   rols('bounds')=boundsvarb
end
 
if grocer_dropna then
   rols(1)($+1)='nonna'
   rols('nonna')=nonna
end
 
if grocer_saturating then
   rols('meth')='saturated ols'
 
   rols(1)($+1)='saturation significance level'
   rols('saturation significance level')=grocer_alphasatur
 
   rols(1)($+1)='significant dummies'
 
   if isempty(dummies) then
      rols('significant dummies')='none'
   else
      if prests then
         [grocer_bnum,fq]=date2num_fq(boundsvarb(1))
         grocer_bnum=grocer_bnum:date2num(boundsvarb(2))
         for i=2:size(boundsvarb,1)/2
            grocer_bnum=[grocer_bnum , date2num(boundsvarb(2*i-1)):date2num(boundsvarb(2*i)) ]
         end
         grocer_datedum=num2date(grocer_bnum(dummies),fq)
         name_dummies='dum_'+grocer_datedum(:)
         rols('significant dummies')=strcat(name_dummies,' - ')
         rols('namex')=[namexos ; name_dummies]
      else
         rols('significant dummies')='at obs '+strcat(dummies,' - ')
      end
   end
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
// prtuniv(rols,foutput)
   prt_ols(rols,%io(2))
   pltuniv(rols,'all')
end
 
endfunction
