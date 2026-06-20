  function rolsecm = olsecm(grocer_p,grocer_namey,varargin)
 
// PURPOSE: Error correction test for cointegration
// ------------------------------------------------------------
// REFERENCE: N. R. Ericsson & J. G. MacKinnon (2002),
// "Distributions of error correction test for cointegration"
// Econometrics Journal, 5, 285-318
// ------------------------------------------------------------
// INPUT:
// * grocer_p = order of time polynomial in the error correction part
//  . -1, no deterministic part (default)
//  .  0, for constant term
//  .  1, for constant plus time-trend
//  .  2, for constant plus quadratic time-trend
// * grocer_namey = the exogenous variable wich can be
//   a time series, a real (nx1) vector or a
//   string equal to the name of a time series or a (nx1) real
//   vector between quotes
// * varargin = arguments which can be:
//   . 'coint=[var1 var2 ... varn]' the cointegrating variables with
//      var1 the variables which t-stat has to be tested.
//   . 'ncoint=x' with x the number of cointegrating variables
//      (exc. the constant) when the user is testing a constrained
///     cointegrating vector (default: the size of the coint vector)
//   . the exogenous variables of the ECM which can be
//     a time series, a real (nx1) vector or a
//     string equal to the name of a time series or a (nx1) real
//     vector between quotes
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . the string 'dropna' if the user wants to delete NAs
//     (this option should be used when dealing with daily and weekly TS)
// ------------------------------------------------------------
// OUTPUT:
// rolsecm = a results tlist with
//   . rolsecm('meth')  = 'olsecm'
//   . rolsecm('y')     = y data vector of the ECM
//   . rolsecm('x')     = x data matrix of the ECM
//   . rolsecm('ecm')     = data matrix of the error correction
//   . rolsecm('nobs')  = # observations in the ECM
//   . rolsecm('nvar')  = # variables in the ECM
//   . rolsecm('beta')  = bhat
//   . rolsecm('yhat')  = yhat
//   . rolsecm('resid') = residuals of the regression
//   . rolsecm('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rolsecm('sige')  = estimated variance of the residuals
//   . rolsecm('sigu')  = sum of squared residuals
//   . rolsecm('ser')  = standard error of the regression
//   . rolsecm('tstat') = t-stats
//   . rolsecm('pvalue') = pvalue of the betas
//   . rolsecm('dw')    = Durbin-Watson Statistic
//   . rolsecm('condindex') = multicolinearity cond index
//   . rolsecm('prescte') = boolean indicating the absence of a
//     constant in the regression
//   . rolsecm('test p-value') = the (approximate) p-value of
//     the test
//   . rolsecm('test crit. value') = the Ericsson-MacKinnon
//     critical value of the test
//   . rolsecm('deterministic') = type of deterministic part
//     in the cointegrating vector
//   . rolsecm('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rolsecm('namey') = name of the y variable of the ECM
//   . rolsecm('namex') = name of the x variables of the ECM
//   . rolsecm('ecm') = location of variables in x and namex
//   . rolsecm('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rolsecm('like') = log-likelihood of the regression
//   . rolsecm('dropna') = boolean indicating if NAs had
//		    been dropped
//   . rolsecm('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux 2007-2013
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_prt=%t;
grocer_dropna=%f;
grocer_coint=[];
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_st=strsubst(varargin(grocer_i),' ','');
      if part(grocer_st,1:5) == 'coint' then
         grocer_coint=str2vec(varargin(grocer_i))
         varargin(grocer_i)=null();
      elseif part(grocer_st,1:6) == 'ncoint' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null();
      elseif grocer_st == 'noprint' then
         grocer_prt=%f;
         varargin(grocer_i)=null();
      elseif grocer_st == 'dropna' then
         grocer_dropna = %t;
         varargin(grocer_i)=null();
      end
   else
      error(typeof(varargin(grocer_i))+': not a valid type in olsecm');
   end
end
 
if grocer_p>2 then
  error('critical values are only available up to a quadratic time-trend');
end
 
// test the format of cointegrating vector
if length(grocer_coint) == 0 then
  error('cointegrating variables are missing');
end
 
[grocer_mats,grocer_names,grocer_prests,grocer_boundsvarb,grocer_nonna]=...
explon(list(grocer_namey,varargin,grocer_coint),...
['endogenous' 'st exogenous' 'lt exogenous'],[],%t,grocer_dropna)
 
grocer_y=grocer_mats(1)
grocer_z=grocer_mats(3)
ncx=size(grocer_z,2)
if ~exists('grocer_ncoint','local') then
   grocer_ncoint=ncx
end
grocer_x=[grocer_mats(2) grocer_z]
 
grocer_namey=grocer_names(1)
grocer_namexos=[grocer_names(2) ; grocer_names(3)]
 
// constructs the determnistic part
ncc=grocer_p+1
if grocer_p >= 0 then
  n=size(grocer_y,1);
 
  grocer_x=[grocer_x ptrend(grocer_p,n)];
  grocer_namexos=[grocer_namexos ; 'cte'];
 
  if grocer_p>0 then
    grocer_namexos=[grocer_namexos ; 't' ];
  end
 
  if grocer_p>1 then
    grocer_namexos=[grocer_namexos ; 't^'+string([2:grocer_p])];
  end
end
 
if length(grocer_ncoint)==0 then
  grocer_ncoint=ncx;
end
 
 
rolsecm= ols2(grocer_y,grocer_x);
rolsecm('meth') = 'olsecm';
 
// computes Ericsson-MacKinnon critical values and p-values
[crit,pval] = critecm(rolsecm('tstat')($-ncx-ncc+1),grocer_ncoint,...
                  grocer_p,rolsecm('nobs'),rolsecm('nvar'));
 
// saves the names, the bounds if the regression involves ts
rolsecm(1)($+1) = 'prests';
rolsecm(1)($+1) = 'namex';
rolsecm(1)($+1) = 'namey';
rolsecm(1)($+1) = 'ecm';
rolsecm(1)($+1) = 'dropna';
rolsecm(1)($+1) = 'test p-value'
rolsecm(1)($+1) = 'test crit. value'
rolsecm(1)($+1) = 'deterministic'
 
rolsecm('prests')=grocer_prests
rolsecm('namex')=grocer_namexos;
rolsecm('namey')=grocer_namey
rolsecm('ecm')=(rolsecm('nvar')-ncx-ncc+1):rolsecm('nvar');
rolsecm('dropna')=grocer_dropna;
rolsecm('test p-value') = pval
rolsecm('test crit. value') =crit
rolsecm('deterministic') =grocer_p
 
if grocer_prests then
   rolsecm(1)($+1) = 'bounds';
   rolsecm('bounds')=grocer_boundsvarb;
end
 
if grocer_dropna then
   rolsecm(1)($+1)='nonna';
   rolsecm('nonna')=grocer_nonna;
end
 
if grocer_prt then
  prt_olsecm(rolsecm);
end
 
endfunction
 
