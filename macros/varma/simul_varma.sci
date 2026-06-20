function y=simul_varma(grocer_nsim,grocer_AR,grocer_ARS,grocer_MA,grocer_MAS,grocer_v,grocer_s,varargin)
 
// PURPOSE: estimate a VARMA model using E4 functions
// the ARMA model has the following form:
// AR(L)*ARS(L^s) y = MA(L)*MAS(L^s) e [+G(L)X]
// where L is the lag operator, X is an optional vector of
// exogenous variables
// ------------------------------------------------------------
// INPUT:
// * grocer_e4_endo = either
//   - a matrix of strings, each one being the name of a
//   variable
//   - a (Txn) real matrix
//   - a ts
//   - a list of variables
//   each element could be a timeseries, a real vector,
//   a real matrix or a string (the name of a variable with
//   one of the types cited above, between quotes)
// * grocer_AR = the matrix [] or a (n x (n*p)) matrix
//   with:
//   - n = # of endogenous variables in grocer_e4_endo
//   - p = # of lags in the AR part of the process
// * grocer_ARS = the matrix [] or a (n x (n*ps)) matrix
//   with ps = # of lags in the seasonal AR part of the
//   process
// * grocer_MA = the matrix [] or a (n x (n*q)) matrix
//   with: q = # of lags in the AM part of the process
// * grocer_MAS = the matrix [] or a (n x (n*qs)) matrix
//   with qs = # of lags in the seasonal MA part of the process
// * grocer_v = a (nx1) vector if the user wants to impose
//   independence between resisduals or a (nxn) matrix in the
//   other case
// * grocer_s = a scalar representing the order of the
//   seasonality
// * varargin = optional arguments that can be:
//   - 'init=own' if the users wants to use as starting values
//   of the optimisation algorithm those given by her as entry
//   of varma
//   - 'exo=xxx' where xxx is the names of exogenous variables
//   which can take the form of a list or a vector of strings
//   - 'Gexo=xxx' where xxx is a vector of coefficients
//   corresponding to the exogenous variables
//   - 'delta=xx' where xx is the increment used to calculate
//   the numerical derivative of the log-likelihood
//   (default: sqrt(%eps)
//   - 'noprint' if the user does not want to print the results
// ------------------------------------------------------------
// OUTPUT:
// result = a results tlist with:
// - result('meth') ='varma'
// - result('y') = (nobsxnendo) matrix of values for the
//   endogenous variables
// - result('namey') = (nvarx1) vector of names for the
//   endogenous variables
// - result('z') = (nobsx(nendo+nexo)) matrix of endogenous and
//   exogenous variables
// - result('nobs') = # of observations
// - result('nendo') = # of endogenous variables
// - result('nvar') = # of endogenous and exogenous variables
// - result('coeff') = (npx1) vector of estimated parameters
// - result('lab') = (npx1) string vector of names for the
//   estimated parameters
// - result('llike') = log-likelihood of the model
// - result('grad') = gradient of the log-likelihood of the
//   model at the estimated parameters
// - result('tstat') = Student's t of the coefficients
// - result('std') = (npx1) Student's t of the coefficients
// - result('exact') = a boolean equal to %T indicatinge that
//   the covariance matrix of the estimated parameters has been
//   calculated with an exact formula
// - result('corr') = (npxnp) correlation matrix
// - result('AIC') = Akaike information criterion
// - result('BIC') = Schwartz information criterion
// - result('theta2mat') = (npx1) string vector making the
//   transformation of the vector of estimated parameters into
//   the matrices of the problem
// - result('seas') = order of the seasonality
// - result('nexo') = # of exogenous variables in the model
// - result('resid') = (nobsx1) vector of filtered residuals
// - result('AR') = the estimated AR part of the ARMA
// - result('MA') = the estimated MA part of the ARMA
// - result('ARS') = the estimated seasonal AR part of the
//   ARMA
// - result('MAS') = the estimated seasonal MA part of the
//   ARMA
// - result('V') = the estimated variance of residuals
// - result('G') = the estimated variance of residuals
// - result('k') = maximum degree of the total AR, MA and G
//   parts
// - result('p') = # of AR parameters
// - result('P') = # of ARS parameters
// - result('q') = # of MA parameters
// - result('Q') = # of MAS parameters
// - result('lagexo') = # of lags applied to the vector of
//   exogenous variables
// - result('n') = n*nendo
// - result('type') = type of the e4 model
// - result('userflag') = a boolean equal to %f indicating
//   that the likelihood function has not been provided by
//   the user (a e4 parameter)
// - result('innov') = a flag indicating that this is an
//   innovation model (a e4 parameter)
// - result('econd') = the criterion used to compute the
//   covariance of the initial state vector (in the current
//   version, econd = 5, that means that the initial value
//   is computed automatically; it is envisaged in future
//   to allow the user to override this condition)
// - result('vcond') = the criterion used to compute the
//   intial value of the state vector (in the current
//   version, econd = 5, that means that the initial value
//   is computed automatically; it is envisaged in future
//   to allow the user to override this condition)
// - result('filtk') = a variable equal to 0 indicating that
//   the Kalman filter has been used (a e4 parameter)
// - result('prests') = a boolean signaling the presence or
//   absence of a ts in the model
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2006
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_E4OPTION=sete4opt('vcond=lyap','var=fac');
grocer_e4_prt=%t
grocer_e4_prtopt=%f
grocer_e4_delta=sqrt(%eps)
grocer_e4_inite4=%t
grocer_fast=%t
grocer_theta2ss=theta2sss
 
grocer_e4_nargin=length(varargin)
for grocer_e4_i=grocer_e4_nargin:-1:1
   select typeof(varargin(grocer_e4_i))
   case 'string' then
      grocer_e4_varaux=strsubst(varargin(grocer_e4_i),' ','')
      if grocer_e4_varaux == 'noprint' then
         grocer_e4_prt=%f
         varargin(grocer_e4_i)=null()
      elseif grocer_e4_varaux == 'prtopt' then
         grocer_e4_prtopt=%t
         varargin(grocer_e4_i)=null()
      elseif grocer_e4_varaux == 'init=own' then
         grocer_e4_inite4=%f
         varargin(grocer_e4_i)=null()
      elseif part(grocer_e4_varaux,1:5) == 'delta' then
         execstr('grocer_e4_'+grocer_e4_varaux)
         varargin(grocer_e4_i)=null()
      elseif part(grocer_e4_varaux,1:6) == 'fast=' then
         execstr('grocer_fast='+part(grocer_e4_varaux,6:length(grocer_e4_varaux)))
         varargin(grocer_e4_i)=null()
      elseif part(grocer_e4_varaux,1:4) == 'exo=' then
         grocer_e4_exo=part(grocer_e4_varaux,5:length(grocer_e4_varaux))
         varargin(grocer_e4_i)=null()
      elseif part(grocer_e4_varaux,1:5) == 'Gexo=' then
         execstr('grocer_e4_Gexo='+part(grocer_e4_varaux,6:length(grocer_e4_varaux)))
         varargin(grocer_e4_i)=null()
      end
    end
end
 
grocer_e4_userflag=0
grocer_e4_innov=1
grocer_e4_zeps = 1e-10
grocer_e4_deps = .00000001;
 
if exists('grocer_e4_exo','local') then
   if ~exists('grocer_e4_Gexo','local') then
      error('Gexo should have been entered along with exo')
   end
   grocer_E4OPTION('econd')='u0'
   grocer_e4_MV=1
   [grocer_exo,grocer_namexos,grocer_prests,grocer_b]=explone(varargin,[],'exogenous')
   [grocer_e4_T,grocer_e4_m] = size(grocer_e4_ex0)
   grocer_e4_r = size(grocer_e4_exo,2)
 
   [grocer_e4_y,grocer_scale]=scalemat(grocer_e4_y0)
   grocer_v=diag(10^(-grocer_scale))*grocer_v*diag(10^(-grocer_scale))
 
   [grocer_e4_exo,grocer_scalex]=scalemat(grocer_e4_exo0)
   grocer_e4_u0=grocer_e4_exo(1,:)
 
   [theta,grocer_e4_theta2mat,grocer_e4_V2theta,grocer_e4_lab,grocer_AR,grocer_ARS,grocer_MA,grocer_MAS,grocer_G,grocer_V,...
   grocer_e4_p,grocer_e4_P,grocer_e4_q,grocer_e4_Q,grocer_e4_g,...
   grocer_e4_s,grocer_e4_k,grocer_e4_n,grocer_e4_np,grocer_e4_type,grocer_e4_vdiag,grocer_e4_ineq,grocer_e4_G2theta] ...
   = arma2param(grocer_e4_m,grocer_AR,grocer_ARS,grocer_MA,grocer_MAS,...
       grocer_v,grocer_s,grocer_e4_Gexo,grocer_e4_r,grocer_e4_namexo);
   y = simmod(theta,grocer_e4_theta2mat,grocer_nsim,grocer_e4_u0)
 
else
   grocer_E4OPTION('econd')='zero'
   grocer_e4_MV=0
   grocer_e4_u0 =[]
   grocer_e4_exo=[]
   grocer_e4_y0=ones(grocer_nsim,size(grocer_AR,1))
   [grocer_e4_T,grocer_e4_m] = size(grocer_e4_y0)
   grocer_e4_r = 0
 
   [theta,grocer_e4_theta2mat,grocer_e4_V2theta,grocer_e4_lab,grocer_AR,grocer_ARS,grocer_MA,grocer_MAS,grocer_G,grocer_V,...
   grocer_e4_p,grocer_e4_P,grocer_e4_q,grocer_e4_Q,grocer_e4_g,...
   grocer_e4_s,grocer_e4_k,grocer_e4_n,grocer_e4_np,grocer_e4_type,grocer_e4_vdiag,grocer_e4_ineq] ...
    = arma2param(grocer_e4_m,grocer_AR,grocer_ARS,grocer_MA,grocer_MAS,grocer_v,grocer_s);
   y = simmod(theta,grocer_e4_theta2mat,grocer_nsim)
end
 
endfunction
 
