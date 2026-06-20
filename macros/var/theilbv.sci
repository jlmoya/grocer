function [results]=theilbv(y,x,nlag,neqs,eqn,theta,weight,decay,scale2,scale,nx)
 
// PURPOSE: do Theil-Goldberger for bvar model (called by
// bvar.sci)
// ------------------------------------------------------------
// INPUT:
// * y = nobs x 1 input vector
// * x = nobs x nvar input explanatory variables matrix
// * nobs = # of observations
// * neqs = # of equations
// * eqn  = # equation number
// * theta= overall tightness
// * weight = scalar or (neqs x neqs) matrix of prior weights
// * decay  = lag decay
// * scale  = scaling vector (determined in bvar)
// * scale2 = scaling vector (determined in bvar)
// * nx     = # of deterministic variables excluding constant
//   term
//--------------------------------------------------------------
// RESULTS: a tlist with
//        results('meth')  = 'bvar'
//        results('beta')  = bhat
//        results('tstat') = t-statistics
//        results('tprob') = t-probabilities
//        results('yhat')  = yhat
//        results('resid') = residuals
//        results('sige')  = e'*e/(n-k)
//        results('rsqr')  = rsquared
//        results('rbar')  = rbar-squared
//        results('nobs')  = nobs
//        results('nvar')  = nvar
//--------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// translated from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[nobs,nvar] = size(x);
 
[nw1,nw2] = size(weight);
if nw1==1 then
  // case of a scalar symmetric weight matrix
  wght = ones(neqs,neqs)*weight;
  for i = 1:neqs
    wght(i,i) = 1;
  end
else
  // general prior weight matrix
  wght = weight;
end
 
// find Doan's sigma(i,j,l)
sigma = zeros(nvar,1);
 
k = 1;
 
for l = 0:nlag-1
   ldecay = (l+1)^decay;
   ldecay = 1/ldecay;
   for j = 1:neqs
      sigma(k,1) = theta*wght(eqn,j)*ldecay*scale2(j,eqn);
      k = k+1;
   end
end
 
// setup prior R-matrix
// R = diagonal matrix with scale(i,1)/S(i,j,l)
R = zeros(nvar,nvar);
 
// N.B. we don't want to divide by zero
// (diffuse prior on the x-variables and constant term)
// so we use nvar-nx-1
 
for i = 1:nvar-nx-1
   R(i,i) = scale(eqn,1)/sigma(i);
end
 
// setup prior c-vector
// equal to scale(i,1)/S(i,j,l) x prior mean
 
c = zeros(nvar,1);
cind = (eqn-1)*nlag+1;
if eqn==1 then
  cind = 1;
end
c(cind,1) = scale(eqn,1)/sigma(cind,1);
 
// form X'X + R'R
xpxrpr = x'*x+R'*R;
 
// find xpxi
[u,s,v]=svd(xpxrpr)
xpxi = u* (diag(ones(size(x,2),1) ./ diag(s))) *v'
 
// form xpy + rpc
xpyrpc = x'*y+R'*c;
 
// find bhat
bet=xpxi*xpyrpc
 
// find y-hat
yhat=x*bet
 
// find residuals
resid=y-yhat
 
// find sige
sigu = resid'*resid;
sige=sigu/(nobs-1)
// Litterman-Doan Bayesian dof
 
// find t-values and probabilities
varbeta = sige*diag(xpxi);
tstat=bet ./ sqrt(varbeta)
 
for i=1:size(bet,1)
   tprob(i)=(1-cdft("PQ",abs(tstat(i)),nobs-1))*2
end
 
// find r-squared, rbar-squared
meany = mean0(y);
ym = y-meany*ones(nobs,1);
rsqr1 = sigu;
rsqr2 = ym'*ym;
rsqr=1-rsqr1/rsqr2
rsqr1 = rsqr1/(nobs-nvar);
// Doan uses nvar=1
rsqr2 = rsqr2/(nobs-1);
rbar=1-rsqr1/rsqr2
 
results=tlist(['results';'meth';'nobs';'nvar';'beta';'yhat';'resid';...
'sigu';'sige';'tstat';'tprob';'rsqr';'rbar';'xpxi'],...
'bvar',nobs,nvar,bet,yhat,resid,sigu,sige,tstat,tprob,rsqr,rbar,xpxi)
endfunction
