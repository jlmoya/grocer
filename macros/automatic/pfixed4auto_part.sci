function results=pfixed4auto_part(results,y,x,z,ncomp,indx,list_vararg)
 
// PURPOSE: performs Fixed Effects Estimation for Panel Data
// (for balanced or unbalanced data) using the within-groups
//     estimation procedure.
// ------------------------------------------------------------
// INPUT:
// * y = a (nobs x neqs) matrix of all of the individual's
//   observations vertically concatenated. This matrix must
//   include in the first column the dependent variable, the
//   independent variables must follow accordingly.
// * index = index vector that identifies each observation with
//   an individual
//   e.g. 1  (first 2 observations  for individual # 1)
//        1
//        2  (next  1 observation   for individual # 2)
//        3  (next  3 observations  for individual # 3)
//        3
//        3
// * z = optional matrix of exogenous variables, dummy
//   variables.
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . rpanel('meth')='panel with fixed effects'
//   . rpanel('y')     = y data vector
//   . rpanel('x')     = x data matrix
//   . rpanel('nobs')  = nobs
//   . rpanel('nvar')  = nvars
//   . rpanel('beta')  = bhat
//   . rpanel('yhat')  = yhat
//   . rpanel('resid') = residuals
//   . rpanel('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rpanel('sige')  = estimated variance of the residuals
//   . rpanel('sigu')  = sum of squared residuals
//   . rpanel('ser')  = standard error of the regression
//   . rpanel('tstat') = t-stats
//   . rpanel('pvalue') = pvalue of the betas
//   . rpanel('condindex') = multicolinearity cond index
//   . rpanel('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rpanel('lliked') = log-likelihood
//   . rpanel('rsqr')  = rsquared
//   . rpanel('rbar')  = rbar-squared
//   . rpanel('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rpanel('pvaluef') = its significance level
// ------------------------------------------------------------
// Copyright: Eric Dubois (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Translated and adpated from Matlab programs
// Written by:
// Carlos Alberto Castro
// National Planning Department
// Bogota, Colombia
// Email: ccastro@dnp.gov.co
 
//****************************************************************************************
// NOTE: James P. LeSage provided corrections on the creation and use of the index
//       vector used to identify the individual's observations.
// and Eric Dubois added his own ones
//****************************************************************************************
 
[nargout,nargin]=argn(0)
[nobs,nz] = size(z);
[nobs,nx] = size(x);
 
index=list_vararg(2)
uniq=unique(index)
 
nindiv = size(uniq,1);
nexo=nx+nindiv+nz
const=zeros(nobs,nindiv)
 
// transformation of all the variables used
// the variables are expressed as deviations from the individual means
// so calculate first the individual means
xm=0*x
zm=0*z
ym=0*y
xm0=zeros(nindiv,nx)
zm0=zeros(nindiv,nz)
ym0=zeros(nindiv,1)
ntypes=ones(nindiv,1)
 
for i = nindiv:-1:1
 
    id_i=find(index == uniq(i))
    ntypei=size(id_i,2)
    ntypes(i)=ntypei
    yi=y(id_i)
    meany=sum(yi)/ntypei
    ym(id_i) = meany
    ym0(i) = meany
    xi = x(id_i,:)
    meanxi=sum(xi,'r')/ntypei
    xm(id_i,:) = ones(ntypei,1) .*. meanxi
    xm0(i,:)=meanxi
    if nz then
       zi = z(id_i,:)
       meanzi=sum(zi,'r')/ntypei
       zm(id_i,:) = meanzi
       zm0(i,:)=meanzi
    end
    const(id_i,i)=1
 
end
 
xnew=[x-xm z-zm]
 
[xpxi,xpxixp]=invxpx(xnew)
bhat=xpxixp*y
yhat=ym+xnew*bhat
 
resid=y-ym-xnew*bhat
sigu=resid'*resid
sige=sigu/(nobs-nexo)
 
iintc = ym0-[xm0 zm0]*bhat
bhat=[iintc ; bhat]
 
vcovar=zeros(nexo,nexo)
vcovar(nindiv+1:nexo,nindiv+1:nexo)=xpxi*sige
vcovar(1:nindiv,1:nindiv)=sige*([xm0 zm0]*xpxi*[xm0 zm0]'+diag(1 ./ ntypes))
vcovar(nindiv+1:nexo,1:nindiv)=-sige*xpxi*[xm0 zm0]'
vocvar(1:nindiv,nindiv+1:nexo)=vcovar(nindiv+1:nexo,1:nindiv)'
 
ser=sqrt(sige)
tmp = diag(vcovar);
tstat = bhat ./ sqrt(tmp)
 
df=nobs-nexo
pvalue=ones(nexo,1)
for i=1:nexo
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
 
results('x') = [const, x , z]
results('nvar')  = nexo
results('yhat')  = yhat
results('beta')  = bhat
results('tstat') = tstat
results('pvalue') = pvalue
results('resid') = resid
results('vcovar') = vcovar
results('sigu') = sigu
results('sige') = sige
 
endfunction
