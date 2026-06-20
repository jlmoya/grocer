function res = multilogit1(y,x,bet0,maxit,tol)
 
// PURPOSE: implements multinomial logistic regression
// Pr(y_i=j) = exp(x_i''bet_j)/sum_l[exp(x_i''bet_l)]
//   where:
//   i    =   1,2,...,nobs
//   j,l  = 0,1,2,...,ncat
// ------------------------------------------------------------
// INPUT:
// * y = response variable vector (nobs x 1)
//       the response variable should be coded sequentially
//       from 0 to ncat, i.e., y in (0,1,2,...,ncat) entries
// * x = matrix of covariates (nobs x nvar)
// NOTE: to include a constant term in each bet_j,
//            include a column of ones in x
// * bet0 = optional starting values for bet (nvar x ncat+1)
//   (default=0)
// * maxit = optional maximum number of iterations (default=100)
// * tol = optional convergence tolerance (default=1e-6)
// ------------------------------------------------------------
// OUTPUT:
// res = a res tlist with:
// - res('meth') = 'multilogit'
// - res('beta') = (nvar x ncat) matrix of bet coefficients:
//                       [bet_1 bet_2 ... bet_ncat] under the
//                       normalization bet_0 = 0
// - res('coeff') = (nvar*ncat x 1) vector of beta coefficients:
//                      [beta_1 ; beta_2 ; ... ; beta_ncat] under
//                      normalization beta_0 = 0
// - res('covb') = (nvar*ncat x nvar*ncat) covariance matrix
//                       of res.bet
// - res('tstat') = (nvar*ncat x 1) vector of t-statistics
// - res('pvalue') = (nvar*ncat x 1) vector of corresponding p-values
// - res('y') = (nobs x ncat+1) matrix of data
// - res('yhat') = (nobs x ncat+1) matrix of fitted values
//                       probabilities: [P_0 P_1 ... P_ncat]
//                       where P_j = [P_1j ; P_2j ; ... ; P_nobsj]
// - res('llike') = unrestricted log likelihood
// - res('lratio') = LR test statistic against intercept-only model (all
//                       bets=0), distributed chi-squared with (nvar-1)*ncat
//                       degrees of freedom
//  - res('nobs') = number of observations
//  - res('nvar') = number of variables
//  - res('ncat') = number of categories of dependent variable
//                       (including the reference category j = 0)
//  - res('count') = vector of counts of each value taken by y, i.e.,
//                       count = [#y=0 #y=1 ... #y=ncat]
//  - res('r2mf') = McFadden pseudo-R^2
//  - res('rsqr') = Estrella pseudo-R^2
//-------------------------------------------------------------------------
// References: Greene (1997), p.914
 
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
// translated, adapated and extended from a matlab program written by:
// Simon D. Woodcock
// CISER / Economics
// Cornell University
// Ithaca, NY
// sdw9@cornell.edu
 
//---------------------------------------------------------
//       ERROR CHECKING AND PRELIMINARY CALCULATIONS
//---------------------------------------------------------
 
[nargout,nargin]=argn(0)
if nargin < 2 then
   error("multilogit: wrong # of input arguments")
end
y = round(y(:));
[nobs,cy] = size(y);
[rx,nvar] = size(x);
 
if rx~=nobs then
   error("multilogit: row dimensions of x and y must agree");
end;
 
// initial calculations
xstd = [1,stdev(x(:,2:nvar),'r')];
x = x ./(ones(nobs,1)*xstd);// standardize x
ymin = min(y);
ymax = max(y);
ncat = ymax-ymin;
d0 =( y*ones(1,ncat+1) ) == ( ones(nobs,1)*(ymin:ymax) )
d = d0(:,2:ncat+1);
// starting values
 
if nargin<3 then
  bet0 = zeros(nvar,ncat+1);
else
   if isempty(bet0) then
      bet0 = zeros(nvar,ncat+1);
   else
       bet0 = bet0 .* (xstd' .*. ones(1,ncat+1));
   end;
end;
 
bet = bet0(:,2:ncat+1);
 
// default max iterations and tolerance
if nargin<4 then maxit = 100; tol = 0.000001;end;
if nargin<5 then tol = 0.000001;end;
 
if nargin>6 then error("multilogit: wrong # of arguments");end;
 
// check nvar and ncat are consistently defined;
[rbet,cbet] = size(bet);
if nvar~=rbet then
  error("multilogit: rows of bet and columns of x do not agree")
end;
 
if ncat ~= cbet then
  error("multilogit: number of columns in bet and categories in y do not agree. "+"check that y is numbered continuously, i.e., y takes values in (0,1,2,3,4,5).entries"+" is ok, y takes values in (0,1,2,3,4,99).entries is not.")
end;
 
//----------------------------------------------------
// MAXIMUM LIKELIHOOD ESTIMATION OF MULTINOMIAL LOGIT
//----------------------------------------------------
 
// likelihood and derivatives at starting values
[P,lnL] = multilogit_lik(y,x,bet,d);
[g,H] = multilogit_deriv(x,d,P,nvar,ncat,nobs);
 
iter = 0;
 
vb = matrix(bet,-1,1);
vg = matrix(g,-1,1);
// newton-raphson update
while (abs(vg'*(H\vg)/length(vg)) > tol) & (iter < maxit)
   iter = iter+1;
   betold = bet;
   vbold = vb;
   vb = vbold-H\vg
   bet=matrix(vb,nvar,ncat)
   [P,lnL] = multilogit_lik(y,x,bet,d);  // update P, lnL
   [g,H] = multilogit_deriv(x,d,P,nvar,ncat,nobs);  // update g,H
   vg = matrix(g,-1,1);
end;
 
//---------------------------------------------------------
//               GENERATE res TLIST
//---------------------------------------------------------
 
bet_mat=bet ./ (xstd' .*. ones(1,ncat))
 
bet=matrix(bet_mat,-1,1)
covb = -inv(H) ./(ones(ncat,ncat) .*. (xstd'*xstd));// restore original scale
stdb = sqrt(diag(covb));
tstat =bet ./stdb
tstat_mat = matrix(tstat,nvar,ncat)
pvalue=ones(nvar,ncat)
df=nobs-ncat*nvar
for i=1:nvar
   for j=1:ncat
      pvalue(i,j)=(1-cdft("PQ",abs(tstat_mat(i,j)),df))*2
   end
end
 
P_0 = ones(nobs,1) - sum(P,'c')
count = [nobs-sum(d) sum(d,'r')]
 
// basic specification testing;
p = count/nobs;
lnLr = nobs*sum(p .*log(p));// restricted log-likelihood: intercepts only
lratio = -2*(lnLr-lnL);
r2mf = 1-lnL/lnLr;// McFadden pseudo-R^2
// Estrella R2
term0 = 2/nobs*lnL
term1 = 1-(lnLr/lnL)^term0
rsqr=1-term1
 
 
res=tlist(['results';'meth';'beta';'covb';'tstat';'pvalue';...
'y';'yhat';'llike';'lratio';'nobs';'nvar';'ncat';'count';'r2mf';'rsqr';'condindex'],...
"multilogit",bet_mat,covb,tstat_mat,pvalue,y,[P_0,P],lnL,lratio,...
nobs,nvar,ncat,count,r2mf,rsqr,bkwols(x))
 
endfunction
