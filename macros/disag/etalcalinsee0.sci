function retal = etalcalinsee0(ly,hx,sratio,s,alpha,mod,ny_prov,opt)
 
// PURPOSE: provide Insee's method for desaggegating time
// series with a high frequency indicator. The regression
// allows for:
//    (a) AR(1) or RW résiduals
//    (b) inclusion or exclusion of a constant
// ------------------------------------------------------------
// INPUT:
// * ly  = a (N x 1) vector of low frequency data
// * hx = a (n x p) matrix of high frequency indicators
// * sratio = the ratio of high to low frequencies
// * s = the high frequency
// * alpha = siginficance elvel used in regressions
// ------------------------------------------------------------
// OUTPUT:
// * retal = a results tlist with:
//   - retal('meth') = 'Insee''s disaggregation'
//   - retal('y estim') = low frequency transformed series (that is
//   differentiated if residuals follow a RW, levle if not)
//   - retal('lf y') = low frequency series
//   - retal('x estim') = a (N x 1) vector of transformed low frequency
//   data
//   - retal('lf x') = a (N x 1) vector of low frequency data
//   - retal('nobs') = # of observations in the regression
//   - retal('resid estim') = a (n x 1) vector of regression
//   residuals
//   - retal('beta') = estimated coefficients of the low frequency
//   regression
//   - retal('tstat') = t stats
//   - retal('pvalue') = pvalue of the betas
//   - retal('prescte') = boolean indicating the presence or
//   absence of a constant in the regression
//   - retal('llike') = the log-likelihood
//   - retal('rho') = autcorrelation coefficient of residuals:
//  . if rho  = ]-1,1[ then the model is estimated in levels
//  . if rho = 1 then the model is estimated in differences
//   - retal('trend') = trend
//   . retal('trend') = 1 if retal('prescte') = %t and
//     rho = 1
//   . retal('trend') = 2 if retal('prescte') = %t and
//     rho ~= 1
//   . retal('trend') = 0 in other cases
//   - retal('y last values') = provisional value for y (and
//   therefore not used in estimation)
//   - retal('hf x') = a (n x k) matrix of exogenous high
//   frequency indicators
//   - retal('high freq') = a scalar, the indicators frequency
//   - retal('freq ratio') = a scalar, the ratio of high to low
//     frequency
//   - retal('aug lf x') = (N x l) matrix of regressors,
//   including the constant or trend if necessary
//   - retal('aug hf x') = (n x l) matrix of regressors,
//   including the constant or trend if necessary
//   - retal('lf yhat') = (N x 1) adjusted low frequency y
//   - retal('lf resid') = (N x 1) low frequency residual
//   - retal('forecasted lf resid') = low frequency residual extended
//   to the incomplete year with the estimated model
//   - retal('hf resid') = high frequency residual in TS
//   form
//   - retal('hf yhat') = high frequency adjusted y
//   ------------------------------------------------------------
// Copyright E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
 
 
// remove last points from the estimation
ly_end = ly(size(ly,1)-ny_prov+1:size(ly,1)) ;
ly = ly(1:size(ly,1)-ny_prov) ;
 
// dimensions of the problem
N = size(ly,1) ;  // N = # of low frequency data
[n,p] = size(hx) ; //n = # of high frequency observations, p=# of indicators
 
// build the aggregation matrix
c =aggreg2(n,N,sratio,opt)  ;
// calculates the low frequency aggregation of high freequency indicators
lx = c*hx ;
 
// find the best annual model between the low frequency data
// and the aggregated high frequency indicator
retal =selecmodel(ly,lx,sratio,alpha,mod)
retal(1)($+1) = 'y last values'
retal(1)($+1) = 'hf x'
retal(1)($+1) ='high freq'
retal(1)($+1) ='freq ratio'
 
retal('hf x') = hx
retal('y last values') = ly_end
retal('high freq') = s
retal('freq ratio') = sratio
 
// recalcul de x selon le modèle sélectionné
retal = agregx(retal,c,sratio) ;
// estimation de la production annuelle et des résidus
retal = foreannu(retal)
retal = foreresid(retal)
 
// high frequency data
retal(1)($+1)='hf yhat'
retal('hf yhat') = retal('aug hf x')*retal('beta')+retal('hf resid')(1:n)
 
endfunction
