function prtbma_g(res,out)
 
// PURPOSE: prints the results of a Bayesian Model Averaging
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following function:
//	bma_g()
// ---------------------------------------------------
// Copyright E. Michaux (2004)
// http://grocer.toolbox.free.fr
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
write(out,' ')
write(out,' ')
write(out,' ')
write(out,'Bayesian model averaging estimates')
write(out,' ')
write(out,'dependent variable: '+string(res('namey')))
if res('prests') then
   ch='estimation period: '
   boundsvar=res('bounds')
   for i=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+'  '
   end
   write(out,ch)
end
write(out,'MCMC	 	= '+string(res('mcmc')))
write(out,'# of obs     	= '+string(res('nobs')))
write(out,'# of var     	= '+string(res('nvar')))
write(out,'g-prior	     	= '+string(res('gprior')))
write(out,'# of draws   	= '+string(res('ndraw')))
write(out,'# of burn-in 	= '+string(res('burnin')))
write(out,'# of models  	= '+string(res('nmod')))															
write(out,'max # of var.	= '+string(res('nvmax')))															
write(out,'time (sec.)  	= '+string(res('time')))		
write(out,' ')
write(out,'standard error of the regression: '+string(res('ser')))
write(out,'sum of squared residuals: '+string(res('sigu')))
write(out,' ')
write(out,'	Model averaging information')
write(out,' ')
 
outi = find(res('mprob') > 0.01) //limit printing to models > 1% post prob
nmod = length(outi)
nvar = res('nvar')
modor = [res('model')(outi,:)' ; ones(1,nmod)]
visor = res('visit')(outi,1)'
mprobor = round(1e5*res('mprob')(outi,1)')/1e3
 
 
matnom = ['models ' ; res('namex') ; 'prob. (%)' ; 'visits']
nb_col4mod=max(1,floor((86-max(length(matnom)))/(8+floor(log10(nmod)))))
nb_tabs=floor(nmod/nb_col4mod)
mod$=nmod
mod0=1
 
while mod0 <= mod$
   index=mod0:min(mod0+nb_col4mod-1,nmod)
   matmod= ['model '+string(index)  ; string(modor(:,index)) ; ...
    string(mprobor(index)) ; string(visor(index))]
   mat2print = [matnom , matmod]
   printmat(mat2print,out)
   write(out,' ')
   mod0=mod0+nb_col4mod
end
 
write(out,' ')
write(out,'	Posterior Estimates')
write(out,' ')
 
mat2print = [' variable   ',' coeff.  ',' prob. (%)']
mat2print  = [mat2print ; string(res('namex')) string(res('beta')) string([100*res('vprob');100])]
printmat(mat2print,out)
 
printsep(out)
 
endfunction
