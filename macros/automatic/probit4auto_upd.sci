function results=probit4auto_upd(results,y,namexos,indx,val,p,ncomp,list_vararg)

nobs=results('nobs')
results('condindex') = bkwols(results('x'))
results('namex')=namexos(indx)

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
results('bic')=-2*like1+results('nvar')*log(nobs)/nobs
results('hq')=-2*like1+results('nvar')*2*log(log(nobs))/nobs


endfunction
