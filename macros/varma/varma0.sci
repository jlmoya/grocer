function [theta,E4OPTION,AR,ARS,MA,MAS,v,theta2mat,V2theta,thetalab,G,V,p,P,q,Q,g,innov,s,k,n,np,T,m,r,vdiag,ineq,MV,userflag,%type,y,exo,u0,scale,scalex,G2theta]=varma0(y0,AR,ARS,MA,MAS,v,s,exo0,Gexo)
 
// PURPOSE: estimate a VARMA model using E4 functions
// the ARMA model has the following form:
// AR(L)*ARS(L^s) y = MA(L)*MAS(L^s) e [+G(L)X]
// where L is the lag operator, X is an optional vector of
// exogenous variables
// ------------------------------------------------------------
// INPUT:
// * endo = either
//   - a matrix of strings, each one being the name of a
//   variable
//   - a (Txn) real matrix
//   - a ts
//   - a list of variables
//   each element could be a timeseries, a real vector,
//   a real matrix or a string (the name of a variable with
//   one of the types cited above, between quotes)
// * AR = the matrix [] or a (n x (n*p)) matrix
//   with:
//   - n = # of endogenous variables in endo
//   - p = # of lags in the AR part of the process
// * ARS = the matrix [] or a (n x (n*ps)) matrix
//   with ps = # of lags in the seasonal AR part of the
//   process
// * MA = the matrix [] or a (n x (n*q)) matrix
//   with: q = # of lags in the AM part of the process
// * MAS = the matrix [] or a (n x (n*qs)) matrix
//   with qs = # of lags in the seasonal MA part of the process
// * v = a (nx1) vector if the user wants to impose
//   independence between resisduals or a (nxn) matrix in the
//   other case
// * s = a scalar representing the order of the
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
// Copyright: Eric Dubois 2004-2007
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
 
userflag=0
%type=1
innov=1
 
[T,m] = size(y0)
if exists('exo0','local') then
   E4OPTION=sete4opt('vcond=lyap','var=fac','econd=u0');
   MV=1
 
   [y,scale]=scalemat(y0)
   v=diag(10^(-scale))*v*diag(10^(-scale))
 
   [exo,scalex]=scalemat(exo0)
 
   [theta,theta2mat,V2theta,thetalab,AR,ARS,MA,MAS,G,V,p,P,q,Q,g,...
   s,k,n,np,vdiag,ineq,G2theta]=arma2param(m,AR,ARS,MA,MAS,...
          v,s,Gexo,r,namexo);
else
   E4OPTION=sete4opt('vcond=lyap','var=fac','econd=zero');
   MV=0
   u0 =[]
   exo=[]
   exo0=[]
   scalex=[]
 
   [y,scale]=scalemat(y0)
   v=diag(10^(-scale))*v*diag(10^(-scale))
 
   [theta,theta2mat,V2theta,thetalab,AR,ARS,MA,MAS,G,V,p,P,q,Q,g,...
   s,k,n,np,vdiag,ineq]= arma2param(m,AR,ARS,MA,MAS,v,s);
end
 
r = size(exo0,2)
z=[y exo]
userflag=0
zeps = 1e-10
deps = .00000001;
filtk = 1
 
endfunction
 
