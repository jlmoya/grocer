function rsur=sur1(y0,X,crit,itmax)
 
// PURPOSE: estimate a set of equations by Zellner seemingly
// unrelated regression method
// ------------------------------------------------------------
// INPUT:
// * y0 = a (nobs x neqs) real matrix
// * x= a (nobs*neqs x nvar) real matrix
// * crit = a real, the convergence criterion
// * itmax = a real, the maximum # of iterations
// ------------------------------------------------------------
// OUTPUT:
// rsur =  a results tlist with:
// - rsur('meth') = 'sur'
// - rsur('y') = a (nobs x neqs) matrix of endogenous variables
// - rsur('x') = a (nobs*neqs x nvar) matrix of exogenous variables
// - rsur('nobs') = # of observations
// - rsur('neqs') = # of estimated equations
// - rsur('ncoef') = # of estimated coefficients
// * rsur('nvar') = a (neqs x 1) vector collecting the # of
//   exogenous variables in each equations
// - rsur('beta') = bhat
// - rsur('yhat') = a (nobs x neqs) matrix of adjusted y
// - rsur('tstat') = t-stats
// - rsur('pvalue') = pvalue of the betas
// - rsur('resid') = a (nobs*neqs x nvar) matrix of estimated
//   residuals
// - rsur('sigma') = covariance matrix of the residuals
// - rsur('vcovar') = covariance matrix of the estimated coeffs
// - rsur('corr') = correlation matrix of the residuals
// - rsur('sigu') = (neqs x neqs) matrix resid'*resid
// * rsur('ser') = (neqs x 1) matrix of standard errors of the
//   regression
// - rsur('dw') = (1 x neqs) Durbin-Watson
// - rsur('llike') = log-likelihood of the estimated model
// - rsur('aic') = Akaïke information criterion
// - rsur('bic') = Schwartz information criterion
// - rsur('hq') = Hannan-Quinn information criterion
// - rsur('prests') = boolean indicating the presence or
// - rsur('condindex') = a (1 x neqs) vector collecting the
//   condition index of each equation
// - rsur('prests') = boolean indicating the presence or
//     absence of a time series in the regression
// - rsur('dropna') = boolean indicating if NAs have
//     been dropped
// - rsur('namecoef') = (ncoef x 1) mame of the coeffcients
// - rsur('namey') = name of endogenous variables
// - rsur('eqs') = list of the neqs equations
// - rsur('coefs') = list of the coefs names in each equation
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013-2019
// http://grocer.toolbox.free.fr/grocer.html
 
[nobs,neqs]=size(y0)
[junk,ncoeffs]=size(X)
ncoefeqs=zeros(neqs,1)
condindex=ones(1,neqs)
 
for i=1:neqs
   Xi=X(1+(i-1)*nobs:i*nobs,:)
   indi=find(sum(abs(Xi),'r') ~= 0)
   Xi=Xi(:,indi)
   ncoefeqs(i)=size(indi,2)
   condindex(i)=bkwols(Xi)
   prescte(i)=~isempty(search_cte(Xi))
end
 
y=y0(:)
convg=crit*2
// uses results from ols as starting values
beta0=ols0(y,X)
resid0=y-X*beta0
nbit=0
 
while (convg > crit & nbit < itmax) then
   nbit=nbit+1
   sigma=zeros(neqs,neqs)
   resd=resid0 ./ (sqrt(nobs-ncoefeqs).*.ones(nobs,1))
   rest=matrix(resd,nobs,neqs)
   sigma=real(rest'*rest)
   sqrtsigma=sigma^(-0.5).*.eye(nobs,nobs)
   sqrtsigmax=sqrtsigma*X
   [bhat,ixpomegam1x]=ols0(sqrtsigma*y,sqrtsigmax)
   resid=y-X*bhat
   convg=sum(abs(bhat-beta0))
   beta0=bhat
   resid0=resid
end
 
resid=matrix(resid0,nobs,neqs)
yhat=y0-resid
tstat=beta0 ./ sqrt(diag(ixpomegam1x))
pvalue=zeros(ncoeffs,1)
ds=diag(sigma)
ser=sqrt(ds)
sigu=resid'*resid
corm=var2cor(sigma)
 
for i=1:ncoeffs
   pvalue(i)=(1-cdfnor("PQ",abs(tstat(i)),0,1))*2
end
 
// durbin-watson
dw=zeros(1,neqs)
for i=1:neqs
   ediff = resid(2:nobs,i)-resid(1:nobs-1,i)
   dw(i) = ediff'*ediff/sigu(i,i)
end
 
llike=-0.5*nobs*neqs*log(2*%pi)-0.5*nobs*log(det(resid'*resid/nobs))-0.5*nobs*neqs
 
aic=llike+2*sum(ncoeffs)/nobs
bic=llike+2*sum(ncoeffs)*log(nobs)/nobs
hq=llike+2*sum(ncoeffs)*log(log(nobs))/nobs
rsur=tlist(['results';'meth';'y';'x';'nobs';'neqs';'ncoef';'nvar';'beta';...
'yhat';'tstat';'pvalue';'resid';'sigma';'vcovar';'corr';'sigu';'ser';'dw';...
'llike';'aic';'bic';'hq';'condindex';'prests';'dropna';'namecoef';'namey';'eqs';'coefs'...
],...
'sur',y0,X,nobs,neqs,ncoefeqs,ncoefeqs,bhat,yhat,tstat,pvalue,resid,...
sigma,ixpomegam1x,corm,sigu,ser,dw,llike,aic,bic,hq,condindex,[],[],[],[],[],[])
 
endfunction
