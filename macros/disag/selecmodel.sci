function  retal = selecmodel(y,x,sratio,alpha,mod)
 
// PURPOSE: Function that selects the model for the residuals:
// - an AR(1) with or without constant
// - a RW with or without constant
// ------------------------------------------------------------
// INPUT:
// * y  = a (N x 1) vector of low frequency data
// * x = a (N x p) matrix of high frequency indicators
// * sratio = the ratio of high to low frequencies
// * alpha = siginficance elvel used in regressions
// ------------------------------------------------------------
// OUTPUT:
// * retal = a results tlist with:
//   - retal('meth') = 'Insee''s disaggregation'
//   - retal('lf y') = annual series
//   - retal('y estim') = annual transformed series (that is
//   differentiated if residuals follow a RW, levle if not)
//   - retal('lf x') = a (N x 1) vector of annual data
//   - retal('x estim') = a (N x 1) vector of transformed annual
//   data
//   - retal('hf x') = a (n x k) matrix of exogenous high
//   frequency indicators
//   - retal('nobs') = # of observations in the regression
//   - retal('resid estim') = a (n x 1) vector of regression
//   residuals
//   - retal('beta') = estimated coefficients of the annual
//   regression
//   - retal('tstat') = t stats
//   - retal('pvalue') = pvalue of the betas
//   - retal('prescte') = boolean indicating the presence or
//   absence of a constant in the regression
//   - retal('llike') = the log-likelihood
//   - retal('rho') = autcorrelation coefficient of residuals:
//      . if rho  = ]-1,1[ then the model is estimated in levels
//      . if rho = 1 then the model is estimated in differences
//   - retal('trend') = trend
//      . retal('trend') = 1 if retal('prescte') = %t and
//        rho = 1
//      . retal('trend') = 2 if retal('prescte') = %t and
//        rho ~= 1
//      . retal('trend') = 0 in other cases
//   ------------------------------------------------------------
// Copyright E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
 
n =size(y,1)
p = size(x,2)
xc = [x ones(n,1)]
 
// create the results tlist
retal = tlist(['results';'meth';'y estim';'lf y';'x estim';'lf x';'nobs';'resid estim';...
'beta';'tstat';'pvalue';'prescte';'llike';'rho';'trend'],'Insee''s disaggregation')
retal('lf y') = y
retal('lf x') = x
 
if mod == 'no' then
    // estimation of an AR(1) model on residuals + and test
    // if a constant is needed
 
   rar1  = olsar(y,xc)
   rar1('prescte') = %t
   pvalue = rar1('pvalue')(p+1)
   if pvalue > alpha then
      rar1  = olsar(y,x)
   end
 
    // estimation of an RW model on residuals + and test
    // if a constant is needed
   rrw = olsrw(y,x,sratio)
 
   if size(rrw('pvalue'),1) == p+1 then
      pvalue = rrw('pvalue')(p+1)
      if pvalue > alpha then
         rrw  = olsrw(y,x,0)
      end
   end
 
   // selection of the model
   if rrw('like') > rar1('like') then
      rsel = rrw
      retal('rho') = 1
      retal('prescte') = rrw('prescte')
 
      if retal('prescte') == %t then
         retal('trend') = 1
      else
        retal('trend') = 0
     end
 
	else
		rsel = rar1
		retal('rho') =  rar1('rho')
 
		retal('prescte') = rar1('prescte')
		if retal('prescte') == %t then
			retal('trend') = 2
		else
			retal('trend') = 0
		end
	end
 
elseif mod == 'rw' then
    // estimation of a RW model on residuals + and test the significance of the constant
	rrw	= olsrw(y,x,sratio)
	pvalue = rrw('pvalue')(p+1)
	if pvalue > alpha then
		rrw  = olsrw(y,x,0)
	end
	
	retal('prescte') = rrw('prescte')
	if retal('prescte') == %t then
			retal('trend') = 1
	else
			retal('trend') = 0
	end
	retal('rho') =1
	rsel = rrw
 
elseif mod == 'ar' then
    // estimation of an AR(1) model on residuals + and test
    // if a constant is needed
	rar1  = olsar(y,xc)
	rar1('prescte') = %t
	pvalue = rar1('pvalue')(p+1)
	if pvalue > alpha then
		rar1  = olsar(y,x)
	end
	
	retal('prescte') = rar1('prescte')
	if retal('prescte') == %t then
		retal('trend') = 2
	else
		retal('trend') = 0
	end
	retal('rho') = rar1('rho')
	rsel = rar1
end
 
retal('y estim') = rsel('y')
retal('x estim') = rsel('x')
retal('nobs') = rsel('nobs')
retal('resid estim') = rsel('resid')
retal('beta') = rsel('beta')
retal('tstat') = rsel('tstat')
retal('pvalue') = rsel('pvalue')
retal('prescte') = rsel('prescte')
retal('llike') = rsel('llike')
 
endfunction
