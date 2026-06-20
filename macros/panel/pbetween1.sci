function res=pbetween1(y,index,x,z)
 
// PURPOSE: performs Random Effects Estimation for Panel Data
//          (for balanced or unbalanced data)
// ------------------------------------------------------------
// INPUT:
// * y  = a (nobs x 1) vector of endogenous variable
// * index = a (nobs x 1) index vector that identifies each
//   observation with an individual
//   e.g. 1  (first 2 observations  for individual # 1)
//        1
//        2  (next  1 observation   for individual # 2)
//        3  (next  3 observations  for individual # 3)
//        3
//        3
// * x = matrix of exogenous variables
// * z = optional matrix of exogenous variables, dummy
//   variables.
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . res('meth')='panel with random effects'
//   . res('y')     = y data vector
//   . res('x')     = x data matrix
//   . res('nobs')  = nobs
//   . res('nvar')  = nvars
//   . res('beta')  = bhat
//   . res('yhat')  = yhat
//   . res('resid') = residuals
//   . res('vcovar') = estimated variance-covariance matrix of
//     beta
//   . res('sige')  = estimated variance of the residuals
//   . res('sige')  = estimated variance of the residuals
//   . res('ser')  = standard error of the regression
//   . res('tstat') = t-stats
//   . res('pvalue') = pvalue of the betas
//   . res('condindex') = multicolinearity cond index
//   . res('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . res('rsqr')  = rsquared
//   . res('rbar')  = rbar-squared
//   . res('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . res('pvaluef') = its significance level
//   . res('gls estimation method') = the gls method used
//   . res('random effects') = the estimation of the individual
//     effects
//   . res('res0') = residuals from the original model
//   . res('alfa') = the gls parameters
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin < 4 then
   z=[]
end
[nobs,nz] = size(z);
[nobs,nx] = size(x);
 
// creation of the id matrix using the vector index
uniq=unique(index)
 
nindiv = size(uniq,1);
nexo=nx+nz
const=zeros(nobs,nindiv)
 
// transformation of all the variables used
// the variables are expressed as deviations from the individual means
// so calculate first the individual means
ym0=zeros(nindiv,1)
xm0=zeros(nindiv,nx)
zm0=zeros(nindiv,nz)
 
for i = 1:nindiv
 
   id_i=find(index == uniq(i))
   yi=y(id_i)
   meany=mean0(yi)
   ym0(i) = meany
   xi = x(id_i,:)
   meanxi=mean0(xi,1)
   xm0(i,:)=meanxi
 
   if nz then
      zi = z(id_i,:)
      meanzi=mean0(zi,1)
      zm0(i,:)=meanzi
   end
   const(id_i,i)=1
 
end
 
indepm0 = [xm0 zm0 ];
res   = ols2(ym0,indepm0);
 
res('meth')='between'
 
// suppress dw which is meaningless
res(1)(16)=[]
res(16)=null()
endfunction
