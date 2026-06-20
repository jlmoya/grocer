function results=probit_update(results,x)

results('condindex') = bkwols(results('x'))

like0=results('llike0')
like1=results('llike')
// McFadden pseudo-R2
results('r2mf') = 1-abs(like1)/abs(like0)
// Estrella R2
term0 = 2/nobs*like0;
term1 = 1/(abs(like1)/abs(like0)^term0);
results('rsqr') = 1-term1
 
// LR-ratio test against intercept model
results('lratio') = 2*(like1-like0)
 
results('aic')=-2*like1+results('nvar')*2
results('bic')=-2*like1+results('nvar')*log(results('nobs'))/results('nobs')
results('hq')=-2*like1+results('nvar')*2*log(log(results('nobs')))/results('nobs')



endfunction
