function rvar=rolvar1(y,nlag,x,nper,first_start,last_start)

// PURPOSE: performs rolling vector autogressive estimation; 
// the function works only with matrices
// ------------------------------------------------------------
// INPUT:
// * y = an (nobs x neqs) matrix of y-vectors
// * nlag = the lag length
// * x = optional matrix of variables (nobs x nx)
// * nper= a scalar, the number of observations kept at each
//     estimation
// * first_start = the index of the first data used for the
//   first estimation
// * first_start = the index of the first data used for the
//   last estimation
// ------------------------------------------------------------
// OUTPUT:
// rvar = a results tlist with:
//   . rvar('meth')  = 'rolling var'
//   . rvar('yall')  = y data vector lagged data included
//   . rvar('y')     = y data vector used in the rhs parts of
//                     the VAR
//   . rvar('x')     = x data matrix
//   . rvar('nvar')  = # exogenous variables
//   . rvar('nobs')  = # observations
//   . rvar('neqs')  = # endogenous variables
//   . rvar('nlag')  = # lags in the VAR
//   . rvar('resid') = residuals, with rvar('resid')(:,i):
//                     residuals for equation # i
//   . rvar('beta')  = bhat, with rvar('beta')(:,i):
//                     coefficients for equation # i
//   . rvar('tstat') = t-stats, with rvar('tstat')(:,i):
//                     t-stat for equation # i
//   . rvar('pvalue')= pvalue of the betas, with
//                      rvar('pvalue')(:,i): p-value for
//                      equation # i
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
//   . rvar('dw')    = Durbin-Watson Statistic, with:
//                    rvar('dw')(i): DW for equation # i
//   . rvar('condindex') = multicolinearity cond index, with
//                         rvar('condindex')(i): cond index for
//                         equation # i
//   . rvar('ftes') = F-stat for the nullity of coefficients other
//          than the constant with f(i): F-stat for equation # i
//   . rvar('fvalues') = their significance level with fvalues(i):
//             significance level for equation # i
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
//   . rvar('prescte') = boolean indicating the presence or
//     absence of a cosntant in the VAR
//   . rvar('nx') = # of exogenous variables in the VAR

[nobs,ny]=size(y)
nx=size(x,2)
nestim=last_start-first_start+1
ncoeff=nx+ny*nlag

yn=zeros(nestim,nper+nlag,ny)
y_all=zeros(nestim,nper,ny)
xn=zeros(nestim,nper,nx)
bet=zeros(nestim,ncoeff,ny)
tstat=zeros(nestim,ncoeff,ny)
pvalues=zeros(nestim,ncoeff,ny)
dw=ones(nestim,ny)
resid=ones(nestim,nper,ny)
fvalues=ones(nestim,ny,ny)
ftes=ones(nestim,ny,ny)
boxq=ones(nestim,ny)
pvalue=ones(nestim,ncoeff,ny)
ser=ones(nestim,ny)
sigu=ones(nestim,ny)
condindex=ones(nestim,ny)
rsqr=ones(nestim,ny)
pvaluef=ones(nestim,ny)
overallf=ones(nestim,ny)
rbar=ones(nestim,ny)
aic=ones(nestim,1)
bic=ones(nestim,1)
hq=ones(nestim,1)
xpxi=zeros(nestim,ncoeff,ncoeff)
vcovar=zeros(nestim,ny*ncoeff,ny*ncoeff)
sigma=zeros(nestim,ny,ny)

prescte=~isempty(search_cte(x))
for iter=1:last_start-first_start+1
   obs=iter+first_start-1
   y_iter=y(obs-nlag:obs+nper-1,:)
   x_iter=x(obs:obs+nper-1,:)
   [bet_i,tstat_i,pvalue_i,dw_i,resid_i,ftes_i,fvalues_i,boxq_i,ser_i,...
   sigu_i,condindex_i,rsqr_i,pvaluef_i,overallf_i,rbar_i,aic_i,bic_i,hq_i,...
   sigma_i,xpxi_i,vcovar_i]...
   =var0(y_iter,nlag,x_iter,prescte)

   yn(iter,:,:)=y_iter   
   y_all(iter,:,:)=y_iter(nlag+1:$,:)
   if ~isempty(x_iter) then
      xn(iter,:,:)=x_iter
   end
   bet(iter,:,:)=bet_i   
   tstat(iter,:,:)=tstat_i   
   pvalue(iter,:,:)=pvalue_i   
   dw(iter,:)=dw_i   
   resid(iter,:,:)=resid_i   
   ftes(iter,:,:)=ftes_i 
   fvalues(iter,:,:)=fvalues_i 
   boxq(iter,:)=boxq_i   
   ser(iter,:)=ser_i   
   sigu(iter,:)=sigu_i   
   condindex(iter,:)=condindex_i   
   rsqr(iter,:)=rsqr_i   
   pvaluef(iter,:)=pvaluef_i   
   overallf(iter,:)=overallf_i   
   rsqr(iter,:)=rsqr_i   
   aic(iter)=aic_i
   bic(iter)=bic_i
   hq(iter)=hq_i
   sigma(iter,:,:)=sigma_i
   xpxi(iter,:,:)=xpxi_i
   vcovar(iter,:,:)=vcovar_i

end

if nlag ~= 0 & prescte then
    rvar=tlist(['results';'meth';'yall';'y';'x';'nvar';'nobs';...
    'neqs';'nlag';'resid';'beta';'tstat';'pvalue';'rsqr';...
    'overallf';'pvaluef';'rbar';'sigu';'ser';'dw';'condindex';...
    'ftest';'fvalues';'boxq';'sigma';'aic';'bic';'hq';'xpxi';...
    'vcovar';'prescte';'nx'],...
    'rolling var',yn,y_all,xn,ny,nobs-nlag,ny,nlag,resid,bet,tstat,pvalue,...
    rsqr,overallf,pvaluef,rbar,sigu,ser,dw,condindex,ftes,...
    fvalues,boxq,sigma,aic,bic,hq,xpxi,vcovar,prescte,nx)

else
    rvar=tlist(['results';'meth';'yall';'y';'x';'nvar';'nobs';...
    'neqs';'nlag';'resid';'beta';'tstat';'pvalue';'sigu';'ser';'dw';'condindex';...
    'boxq';'sigma';'aic';'bic';'hq';'xpxi';'vcovar';...
    'prescte';'nx'],...
    'rolling var',y,y(nlag+1:nobs,:),xn,ny,nobs-nlag,ny,nlag,resid,bet,tstat,pvalue,...
    sigu,ser,dw,condindex,...
    boxq,sigma,aic,bic,hq,xpxi,vcovar,prescte,nx)

end


endfunction
