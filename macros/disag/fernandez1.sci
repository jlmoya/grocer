function [y,res]=fernandez1(Y,x,ta,s)
 
// PURPOSE: Temporal disaggregation using the Fernandez method
// ------------------------------------------------------------
// INPUT:
// * Y = Nx1 ---> vector of low frequency data
// * x = nxp ---> matrix of high frequency indicators
//   (without intercept)
// * ta = type of disaggregation:
//   - ta = -1 ---> sum (flow)
//   - ta = 0 ---> average (index)
//   - ta = k ---> k th element ---> interpolation
// * s = number of high frequency data points for each low
//   frequency data points:
//   - s= 4 ---> annual to quarterly
//   - s=12 ---> annual to monthly
//   - s= 3 ---> quarterly to monthly
// ------------------------------------------------------------
// OUTPUT:
// * y = the disaggregated variable
// * res = a results tlist with:
//   - res('meth')      ='Fernandez';
//   - res('ta')        = type of disaggregation
//   - res('nobs_lf')   = nobs. of low frequency data
//   - res('nobs_hf')   = nobs. of high-frequency data
//   - res('pred')      = number of extrapolations
//   - res('s')         = frequency conversion between low and high freq.
//   - res('p')         = number of regressors (including intercept)
//   - res('y_lf')      = low frequency data
//   - res('indicator') = high frequency indicators
//   - res('y_hf')      = high frequency estimate
//   - res('y_dt')      = high frequency estimate: standard deviation
//   - res('y_up')      = high frequency estimate: sd + sigma
//   - res('y_lo')      = high frequency estimate: sd - sigma
//   - res('resid_hf')  = high frequency residuals
//   - res('resid_lf)   = low frequency residuals
//   - res('beta')      = estimated model parameters
//   - res('sd')        = estimated model parameters: standard deviation
//   - res('tstat')     = estimated model parameters: t ratios
//   - res('pvalue')    = pvalue of the betas
//   - res('aic')       = Information criterion: AIC
//   - res('bic')       = Information criterion: BIC
// ------------------------------------------------------------
// REFERENCE: Fernández, R.B.(1981)""""Methodological note on the
// estimation of time series"""", Review of Economic and Statistics,
// vol. 63, n. 3, p. 471-478.
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
// translated and adpated to Scilab from Matlab programs written
// by:
// Enrique M. Quilis
// Instituto Nacional de Estadistica
// Paseo de la Castellana, 183
// 28046 - Madrid (SPAIN)
 
// ------------------------------------------------------------
// Size of the problem
 
[N,M] = size(Y);
// Size of low-frequency input
[n,p] = size(x);
// Size of p high-frequency inputs (without intercept)
 
// ------------------------------------------------------------
// Preparing the X matrix: including an intercept
 
[N,M] = size(Y);
// Size of low-frequency input
[n,p] = size(x);
// Size of p high-frequency inputs (without intercept)
 
// ------------------------------------------------------------
// Preparing the X matrix: including an intercept
 
e = ones(n,1);
x = [e,x];
// Expanding the regressor matrix
p = p+1;
// Number of p high-frequency inputs (plus intercept)
 
// ------------------------------------------------------------
// Generating the aggregation matrix
 
C = aggreg2(n,N,s,ta);
// -----------------------------------------------------------
// Expanding the aggregation matrix to perform
// extrapolation if needed.
 
// -----------------------------------------------------------
// Temporal aggregation of the indicators
X = C*x;
 
// -----------------------------------------------------------
// Estimation
 
I = eye(n,n);
w = I;
LL = zeros(n,n);
for i = 2:n
  LL(i,i-1) = -1;
  // Auxiliary matrix useful to simplify computations
end
//evec=ones(N,1)
 
Aux = I+LL;
w = invxpx(Aux);
// High frequency VCV matrix (without sigma_a)
W = C*w*C';
// Low frequency VCV matrix (without sigma_a)
Wi=pinv(W)
bet=pinv(X'*Wi*X)*X'*Wi*Y
// beta ML estimator
U = Y-X*bet;
// Low frequency residuals
scp = U'*Wi*U;
// Weighted least squares
sigma_a = scp/(N-p);
// sigma_a ML estimator
L = w*C'*Wi;
// Filtering matrix
u = L*U;
// High frequency residuals
llike = -(N/2)*log(2*%pi*sigma_a)-1/2*log(det(W))-N/2;
// log-likelihood
 
// ----------------------------------------------------------
// Temporally disaggregated time series
 
y = x*bet+u;
 
// -----------------------------------------------------------
// Information criteria
// Note: p is NOT expanded to include the innovational parameter
 
aic = log(sigma_a)+2*p/N;
bic = log(sigma_a)+log(N)*p/N;
 
// -----------------------------------------------------------
// VCV matrix of high frequency estimates
 
sigma_beta = sigma_a*inv(X'*Wi*X);
 
VCV_y = sigma_a*(eye(n,n)-L*C)*w+(x-L*X)*sigma_beta*((x-L*X)');
 
d_y = sqrt(diag(VCV_y));
// Std. dev. of high frequency estimates
y_li = y-d_y;
// Lower lim. of high frequency estimates
y_ls = y+d_y;
// Upper lim. of high frequency estimates
 
 
// Student and their pvalue
sd=sqrt(diag(sigma_beta))
tstat = bet ./ sd
df=N-p
pvalue=ones(p,1)
for i=1:p
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
 
 
res = tlist(['results';'meth';'ta';'nobs_lf';'nobs_hf';...
'pred';'s';'p';'y_lf';'indicator';'y_hf';'y_dt';'y_up';...
'y_lo';'resid';'resid_U';'beta';'sd';'tstat';'pvalue';...
'aic';'bic';'llike'],...
'Fernandez',ta,N,n,n-N*s,s,p,Y,x,y,d_y,y_ls,y_li,u,U,bet,...
sd,tstat,pvalue,aic,bic,llike)
endfunction
