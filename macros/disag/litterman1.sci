function [y,res]=litterman1(Y,x,ta,s,delta,typemin,optfunc,opt_optim)
 
// PURPOSE: Temporal disaggregation using the Litterman method
// ------------------------------------------------------------
// INPUT:
// * Y = Nx1 ---> vector of low frequency data
// * x = nxp ---> matrix of high frequency indicators (without
//   intercept)
// * ta = type of disaggregation
//      ta=-1 ---> sum (flow)
//      ta=0 ---> average (index)
//      ta=i ---> i th element (stock) ---> interpolation
// * s = number of high frequency data points for each low
//       frequency data point
//      s= 4 ---> annual to quarterly
//      s=12 ---> annual to monthly
//      s= 3 ---> quarterly to monthly
// * typemin = estimation method:
//      typemin='wls' ---> weighted least squares
//      typemin='llike' ---> maximum likelihood
// * optfunc =  the name of the optimisation function
//   (optim or optimg)
// * opt_optim = a tlist, collecting the options to
//   the optimisation function
// ------------------------------------------------------------
// OUTPUT:
// * y = the disaggregated variable
// * res= a result tlist with:
//   - res('meth') = 'Litterman'
//   - res('ta') = type of disaggregation
//   - res('nobs_lf') = nobs of low frequency data
//   - res('nobs_hf') = nobs of high-frequency data
//   - res('pred') = number of extrapolations
//   - res('s') = frequency conversion between low and high freq
//   - res('p') = number of regressors (including intercept)
//   - res('y_lf') = low frequency data
//   - res('x') = high frequency indicators
//   - res('y_hf') = high frequency estimate
//   - res('y_dt') = high frequency estimate: standard deviation
//   - res('y_up') = high frequency estimate: sd + sigma
//   - res('y_lo') = high frequency estimate: sd - sigma
//   - res('resid') = high frequency residuals
//   - res('resid_U') = low frequency residuals
//   - res('beta') = estimated model parameters
//   - res('sd') = standard deviation of the estimated model
//     parameters
//   - res('tstat') = t ratios of the estimated model parameters
//   - res('pvalue')    = pvalue of the betas
//   - res('rho') = innovational parameter
//   - res('aic') = Information criterion: AIC
//   - res('bic') = Information criterion: BIC
//   - res('typemin') = method of estimation
//   - res('llike') = Log-likelihood at the estimated parameters
//   - res('sigma') = Variance at the estimated parameters
// ------------------------------------------------------------
// REFERENCE: Litterman, R.B. (1983) """"A random walk, Markov
// model for the distribution of time series"""", Journal of
// Business and Economic Statistics, vol. 1, n. 2, p. 169-173.
// ------------------------------------------------------------
// Copyright Eric Dubois 2005-2012
// http://grocer.toolbox.free.fr/grocer.html
// translated and adpated to Scilab from a Matlab program
// written by:
// Enrique M. Quilis
// Instituto Nacional de Estadistica
// Paseo de la Castellana, 183
// 28046 - Madrid (SPAIN)
 
 
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
 
C = aggreg1(n,s,ta);
// -----------------------------------------------------------
// Expanding the aggregation matrix to perform
// extrapolation if needed.
 
if n>s*N then
  pred = n-s*N;
  // Number of required extrapolations
  C = [C,zeros(N,pred)];
else
  pred = 0;
end
 
// -----------------------------------------------------------
// Temporal aggregation of the indicators
 
X = C*x;
 
I = eye(n,n);
w = I;
LL = zeros(n,n);
for i = 2:n
  LL(i,i-1) = -1;
  // Auxiliary matrix useful to simplify computations
end
 
evec=ones(N,1)
 
// -----------------------------------------------------------
// Give good starting values
b0=ols0([0 ; Y(1:$-1)],[0*X(1,:) ; X(1:N-1,:)])
U0=Y-X*b0
rho0=abs(sqrt(abs(U0(2:$)'*U0(1:$-1)/sum(U0(2:$).^2))))*sign(U0(2:$)'*U0(1:$-1))
 
// Define the function to minimize
select typemin
 
case 'llike' then
   deff('[f,g,ind]=grocer_fg(parm,ind,Y,X,LL,C,N,evec)',...
      ['f=litterman_like(parm,Y,X,LL,C,N,evec)';...
      'g=(litterman_like(parm+delta,Y,X,LL,C,N,evec)-litterman_like(parm-delta,Y,X,LL,C,N,evec))/2/delta'])
 
case 'wls' then
   deff('[f,g,ind]=grocer_fg(parm,ind,Y,X,LL,C,N,evec)',...
      ['[l,f]=litterman_like(parm,Y,X,LL,C,N,evec)';...
      '[l,g1]=litterman_like(parm+delta,Y,X,LL,C,N,evec)';...
      '[l,g2]=litterman_like(parm-delta,Y,X,LL,C,N,evec)';...
      'g=(g1-g2)/delta'])
 
end
 
// provide minimization
select optfunc
case 'optim' then
   execstr('[llike,rho,g] = optim(list(grocer_fg,Y,X,LL,C,N,evec)'+...
   opt_optim('optim ineq')+',rho0'+opt_optim('optim')+')')
 
case 'optimg' then
    warning('constraints are not taken into account with optimg')
   [llike,rho,g] = optimg(list(grocer_fg,Y,X,LL,C,N,evec),list(litterman_like,Y,X,LL,C,N,evec),...
       ,rho0,opt_optim('optim'),opt_optim('nelmead'),opt_optim('convg'));
else
   error('not an available optimisation function'+optfunc)
end
execstr('[llike,rho,g] = optim(list(grocer_fg,Y,X,LL,C,N,evec)'+grocer_opt_optim('optim ineq')+...
                                       ',rho0'+grocer_opt_optim('optim')+')')
 
[llike,sigma_a,bet,w,U,sqrtwi]=litterman_like(rho,Y,X,LL,C,N,evec)
llike=-llike
 
wi=sqrtwi*sqrtwi
// beta ML estimator
L = w*C'*wi;
// Filtering matrix
u = L*U;
// High frequency residuals
 
// -----------------------------------------------------------
// Temporally disaggregated time series
 
y = x*bet+u;
 
// -----------------------------------------------------------
// Information criteria
// Note: p is expanded to include the innovational parameter
 
aic = log(sigma_a)+2*p/N;
bic = log(sigma_a)+log(N)*p/N;
 
// -----------------------------------------------------------
// VCV matrix of high frequency estimates
 
sigma_beta = sigma_a*invxpx(sqrtwi*X)
sd=sqrt(diag(sigma_beta))
 
VCV_y = sigma_a*(eye(n,n)-L*C)*w+(x-L*X)*sigma_beta*((x-L*X)');
 
d_y = sqrt(diag(VCV_y));
// Std. dev. of high frequency estimates
y_li = y-d_y;
// Lower lim. of high frequency estimates
y_ls = y+d_y;
// Upper lim. of high frequency estimates
 
// Student and their pvalue
tstat = bet ./ sd
df=N-p
pvalue=ones(p,1)
for i=1:p
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
// save results in a tlist
res = tlist(['results';'meth';'ta';'nobs_lf';'nobs_hf';...
'pred';'s';'p';'y_lf';'indicator';'y_hf';'y_dt';'y_up';...
'y_lo';'resid';'resid_U';'beta';'sd';'tstat';'pvalue';...
'rho';'aic';'bic';'typemin';'llike';'sigma'],...
'Litterman',ta,N,n,pred,s,p,Y,x,y,d_y,y_ls,y_li,u,U,bet,...
sd,tstat,pvalue,rho,aic,bic,typemin,llike,...
sigma_a)
 
endfunction
