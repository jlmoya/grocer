function [bet,tstat,pvalue,dw,resid,ftes,fvalues,boxq,ser,sigu,condindex,rsqr,pvaluef,overallf,rbar,aic,bic,hq,sigma,xpxi,var_A]=var0(y,nlag,z,prescte)
 
// PURPOSE: performs vector autogressive estimation
//          but returns only vectors and matrices
// ------------------------------------------------------------
// INPUT:
// * y    = an (nobs x neqs) matrix of y-vectors
// * nlag = the lag length
// * x    = optional matrix of variables (nobs x nx)
//  (NOTE: constant vector automatically included)
// ------------------------------------------------------------
// OUTPUT:
// * beta  = bhat, with beta(:,i): coefficients for equation # i
// * tstat = t-stats, with tstat(:,i): t-stat for equation # i
// * pvalue = pvalue of the betas, with pvalue(:,i): p-value
//            for equation # i
// * dw = Durbin-Watson Statistic, with dw(i): DW for
//        equation # i
// * resid = residuals, with resid(:,i): residuals for equation
//           # i
// * ftes = F-stat for the nullity of coefficients other than
//          the constant with f(i): F-stat for equation # i
// * fvalues = their significance level with fvalues(i):
//             significance level for equation # i
// * boxq = Box Q-stat, with boxq(i) Box Q-stat for equation # i
// * ser = standard errors of the regression with ser(i): standard
//          error for equation # i
// * sigu = sums of squared residuals with sigu(:,i): sum of
//           squared residuals for equation # i
// * condindex = multicolinearity cond index, with condindex(i):
//               cond index for equation # i
// * rsqr  = rsquared, with rsqr(i): rsquared for equation # i
// * pvaluef = their significance level with rvar('pvaluef')(i):
//             significance level for equation # i
// * overallf = F-stat for the nullity of coefficients other than
//              the constant with: rvar('f')(i): F-stat for
//              equation # i
// * rbar  = rbar-squared
// * aic = Akaïke information criterion
// * bic = Schwartz information criterion
// * hq = Hannan-Quinn information criterion
// * sigma = (neqs x neqs) var-covar matrix of the
//                     regression
// * xpxi = inv(X'X)
// * vcovar = variance matrix of the vector of all coefficents
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapetd from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
[nobs,neqs] = size(y);
 
// adjust nobs to feed the lags
nobse = nobs-nlag;
xlag = mlagb(y,nlag)
nx=size(z,2)
nvar = neqs*nlag+nx
 
// form x-matrix
xmat = [xlag(nlag+1:nobs,:),z]
 
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
   boxq(:,j)=(rtrunc'*rtrunc/qres('sigu')-1)*5/6*nobse/(nobse/6-1);
 
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
            ftes(r,j) = (sigr-rols('sigu'))/nlag/(rols('sigu')/(nobse-nvar))
            fvalues(r,j) = 1-cdff("PQ",ftes(r,j),nlag,nobse-nvar);
         end
      end
   end
end
// end of loop over equations
 
xpxi=rols('vcovar')/rols('sige')
sigma=resid'*resid/(nobse-nvar)
var_A=sigma .*. xpxi
 
// compute t-probs
for i=1:nvar
   for j=1:neqs
      pvalue(i,j) = (1-cdfnor("PQ",abs(tstat(i,j)),0,1))*2
  end
end
 
aic=log(det(sigma))+2*nvar*neqs/nobse
bic=log(det(sigma))+2*nvar*neqs*log(nobse)/nobse
hq=log(det(sigma))+2*nvar*neqs*log(log(nobse))/nobse
 
endfunction
