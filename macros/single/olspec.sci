function [rols]=olspec(grocer_namey0,varargin)
 
// PURPOSE: perform ordinary least-squares and standard
// specification test (Chow in-sample stability tests computed
// at 50% and 90% of the sample; Doornik and Hansen normality
// test; heteroskedasticity test called xi² by D.F. Hendry;
// AutoRegressive Lagrange multiplier tests at order 4) or
// any tests given by the user
// ------------------------------------------------------------
// INPUT:
// * grocer_namey0 = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (nxp) vector
//   . a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   . the string 'arlm(n)' where n is the order of the ar
//     Lagrange multiplier test if the user wants another lag
//     than 4
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
// ------------------------------------------------------------
// OUTPUT:
// rols = a results tlist with
//   . rols('meth')  = 'ols'
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
//   . rols('like') = log-likelihood of the regression
//   . rols('rsqr')  = rsquared
//   . rols('rbar')  = rbar-squared
//   . rols('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rols('pvaluef') = its significance level
//   . rols('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rols('namex') = name of the y variable
//   . rols('namey') = name of the x variables
//   . rols('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rols('name_test') = the names of the specification
//   . rols('spec_test') = a matrix with the values of the
//     statistics of the specification tests in column 1 and
//     the corresponding p-values in column 2
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2022
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_dropna=%f
grocer_prt = %t
grocer_nar = 4
grocer_ltest=emptystr()
grocer_names=tlist(['names';'jbnorm';'doornhans';'hetero_sq';...
     'chowtest';'predfailin';'arlm';'reset'],'Jarque & Bera',...
     'Doornik & Hansen','hetero x_squared','Chow',...
     'Chow pred. fail. ','AR','reset')
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi=strsubst(varargin(grocer_i),' ','')
      if grocer_argi == 'noprint' then
         varargin(grocer_i)=null()
         grocer_prt = %f
      else
         str4=part(grocer_argi,[1:4])
         str5=part(grocer_argi,[1:5])
         str7=part(grocer_argi,[1:7])
         if str5 == 'arlm(' then
            grocer_ltest='test=predfailin(0.5),predfailin(0.9),doornhans,'+varargin(grocer_i)+',hetero_sq'
            varargin(grocer_i)=null()
         elseif str4 == 'test' then
            grocer_ltest=varargin(grocer_i)
            varargin(grocer_i)=null()
         elseif str7 == 'newname' then
            indcom=strindex(grocer_argi,',')
            grocer_names(1)($+1)=part(grocer_argi,strindex(grocer_argi,'(')+1:indcom-1)
            grocer_names($+1)=part(grocer_argi,indcom+1:strindex(grocer_argi,')')-1)
            varargin(grocer_i)=null()
         elseif grocer_argi == 'dropna' then
            grocer_dropna=%t
            varargin(grocer_i)=null()
         end
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
   typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
[y,namey,x,namexos,prests,boundsvarb,nonna]=...
explouniv(grocer_namey0,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
[rols]=olspec1(y,x,grocer_names,grocer_ltest,test_spec0)
// saves the names, the bounds if the regression involves ts
rols(1)($+1) = 'prests'
rols(1)($+1) = 'namex'
rols(1)($+1) = 'namey'
rols('prests')=prests
rols('namex')=namexos
rols('namey')=namey
if prests then
   rols(1)($+1) = 'bounds'
   rols('bounds')=boundsvarb
end
 
rols(1)($+1) = 'dropna'
rols('dropna')=grocer_dropna
if grocer_dropna then
   rols(1)($+1)='nonna'
   rols('nonna')=nonna
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
// prtuniv(rols,foutput)
   prt_ols(rols,%io(2))
   pltuniv(rols,'all')
end
 
endfunction
