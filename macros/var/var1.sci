function [rvar]=var1(y,nlag,x,nocte)
 
// PURPOSE: performs vector autogressive estimation
// ------------------------------------------------------------
// INPUT:
// * y = an (nobs x neqs) matrix of y-vectors
// * nlag = the lag length
// * x = optional matrix of variables (nobs x nx)
//   (NOTE: constant vector automatically included)
// * 'nocte' if the user doesn't want a constant in the model
// ------------------------------------------------------------
// OUTPUT:
// rvar = a results tlist with:
//   . rvar('var')   = 'var'
//   . rvar('yall')  = y data vector lagged data included
//   . rvar('y')     = y data vector used in the rhs parts of
//                     the VAR
//   . rvar('x')     = x data matrix
//   . rvar('nvar')  = # exogenous variables
//   . rvar('nobs')  = # observations
//   . rvar('neqs')  = # endogenous variables
//   . rvar('nlag')  = # lags
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
//   . rvar('overallf')     = F-stat for the nullity of coefficients
//                     other than the constant with:
//                     rvar('f')(i): F-stat for equation # i
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
//   . rvar('ftest') = matrix of causality tests of each
//       variable (in column) in each equation (in row)
//   . rvar('fvalues') = the corresponding p-values
//   . rvar('boxq') = Box Q-stat, with rvar('boxq')(i):
//                    Box Q-stat for equation # i
//   . rvar('sigma') = (neqs x neqs) var-covar matrix of the
//                     regression
//   . rvar('aic') = Akaike information criterion
//   . rvar('bic') = Schwartz information criterion
//   . rvar('hq') = Hannan-Quinn information criterion
//   . rvar('xpxi') = inv(X'X)
//   . rvar('vcovar') = variance matrix of the vector of all
//     coefficents
//   . rvar('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
// ------------------------------------------------------------
// Copyright Eric Dubois 2002-2013
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[nargout,nargin] = argn(0)
[nobs,neqs] = size(y);
 
nx = 0;
 
z=ones(nobs-nlag,1)
if nargin == 4 then
   if nocte == 'nocte' then
      z=[]
   end
end
 
// adjust nobs to feed the lags
nobse = nobs-nlag;
xlag = mlagb(y,nlag)
nx=size(x,2)+size(z,2)
nvar = neqs*nlag+nx
 
// form x-matrix
if nx then
  xmat = [xlag(nlag+1:nobs,:),x,z]
else
  xmat = [xlag(nlag+1:nobs,:),z];
end
 
prescte=~isempty(search_cte(xmat))
bet=ones(nvar,neqs)
tstat=ones(nvar,neqs)
dw=ones(1,neqs)
resid=ones(nobse,neqs)
ftes=ones(neqs,neqs)
fvalues=ones(neqs,neqs)
boxq=ones(1,neqs)
pvalue=ones(nvar,neqs)
ser=ones(1,neqs)
sigu=ones(1,neqs)
condindex=ones(1,neqs)
rsqr=ones(1,neqs)
pvaluef=ones(1,neqs)
overallf=ones(1,neqs)
rbar=ones(1,neqs)
 
// pull out each y-vector and run regressions
for j = 1:neqs
 
   yvec = y(nlag+1:nobs,j);
   rols=ols2(yvec,xmat)
   bet(:,j)=rols('beta')
   tstat(:,j)=rols('tstat')
   dw(:,j)=rols('dw')
   resid(:,j)=rols('resid')
   ser(:,j)=rols('ser')
   sigu(:,j)=rols('sigu')
   condindex(:,j)=rols('condindex')
   // do the Q-statistics
   // use residuals to do Box-Pierce Q-stats
   // contrary to J.P LeSage:
   // use lags =  (1/6)*nobs
 
   elag = mlag(rols('resid'),nobse/6);
   // feed the lags
   etrunc = elag(nobse/6+1:nobse,1);
   rtrunc = resid(nobse/6+1:nobse,j);
 
   qres = ols1(rtrunc,etrunc);
   boxq(:,j)=(rtrunc'*rtrunc/qres('sigu')-1)...
              *5/6*nobse/(nobse/6-1);
 
   if nlag ~= 0 & prescte then
      rsqr(:,j)=rols('rsqr')
      pvaluef(:,j)=rols('pvaluef')
      overallf(:,j)=rols('f')
      rbar(:,j)=rols('rbar')
 
 
    // form x matrices for joint F-tests
    // exclude each variable from the model sequentially
 
      for r = 1:neqs
         if r ~= j then
            xtmp = xmat
            xtmp(:,neqs*[0:nlag-1]+r)=[]
         // we have an xtmp matrix that excludes 1 variable
         // add deterministic variables (if any) and constant
         // term
         // get ols residual vector
            b = ols0(yvec,xtmp);
         // using Cholesky solution
            etmp = yvec-xtmp*b;
            sigr = etmp'*etmp;
         // joint F-test for variables r
            ftes(r,j) = (sigr-rols('sigu'))/nlag/...
                     (rols('sigu')/(nobse-nvar))
            fvalues(r,j) = 1-cdff("PQ",ftes(r,j),nlag,nobse-nvar);
         end
      end
   end
end
// end of loop over equations
 
xpxi=rols('vcovar')/rols('sige')
sigma=resid'*resid/nobse
llike=-0.5*nobse*log(det(sigma))-0.5*nobse*neqs*log(2*%pi)-0.5*nobse*neqs
aic=-2*llike+2*nvar*neqs+neqs*(neqs+1)
bic=-2*llike+(nvar*neqs+0.5*neqs*(neqs+1))*log(nobse*neqs)
hq=-2*llike+(2*nvar*neqs+neqs*(neqs+1))*log(log(nobse*neqs))
 
var_A=xpxi .*. sigma*nobse/(nobse-rols('nvar'))
 
// compute t-probs
for i=1:nvar
   for j=1:neqs
      pvalue(i,j) = (1-cdfnor("PQ",abs(tstat(i,j)),0,1))*2
  end
end
 
if nlag ~= 0 & prescte then
    rvar=tlist(['results';'meth';'yall';'y';'x';'nvar';'nobs';...
    'neqs';'nlag';'resid';'beta';'tstat';'pvalue';'rsqr';...
    'overallf';'pvaluef';'rbar';'sigu';'ser';'dw';'condindex';...
    'ftest';'fvalues';'boxq';'sigma';'sigma_ols';'llike';'aic';'bic';'hq';'xpxi';...
    'vcovar';'prescte';'nx'],...
    'var',y,y(nlag+1:nobs,:),xmat,nvar,nobse,neqs,nlag,resid,bet,tstat,pvalue,...
    rsqr,overallf,pvaluef,rbar,sigu,ser,dw,condindex,ftes,...
    fvalues,boxq,sigma,sigma*nobse/(nobse-rols('nvar')),llike,aic,bic,hq,xpxi,var_A,prescte,nx)
else
    rvar=tlist(['results';'meth';'yall';'y';'x';'nvar';'nobs';...
    'neqs';'nlag';'resid';'beta';'tstat';'pvalue';'sigu';'ser';'dw';'condindex';...
    'boxq';'sigma';'sigma_ols';'llike';'aic';'bic';'hq';'xpxi';'vcovar';...
    'prescte';'nx'],...
    'var',y,y(nlag+1:nobs,:),xmat,nvar,nobse,neqs,nlag,resid,bet,tstat,pvalue,...
    sigu,ser,dw,condindex,...
    boxq,sigma,sigma*nobse/(nobse-rols('nvar')),llike,aic,bic,hq,xpxi,var_A,prescte,nx)
end
 
endfunction
