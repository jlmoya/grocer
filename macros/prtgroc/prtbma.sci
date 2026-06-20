function prtbma(res,out)
 
// PURPOSE: prints the results of a Bayesian Model Averaging
// out
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following function:
//	bma_nc2()
// ---------------------------------------------------
// Copyright E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
 write(out,'****************************************************************************************')
write(out,'	Bayesian Model Averaging Estimates')
write(out,' ')
mat2print=['dependent variable: ' string(res('namey'));
'R-squared   = ' string(res('rsqr')) ;
'sigma^2     = ' string(res('sige')) ;
'# of obs    = ' string(res('nobs')) ;
'# of var    = ' string(res('nvar')) ;
'# of draws  = ' string(res('ndraw')) ;
'nu,lam,phi  = ' string(res('nu'))+', '+string(res('lam'))+', '+string(res('phi')) ;
'# of models = ' string(res('nmod')) ;															
'time (sec.) = ' string(res('time')) ]		
write(out,' ')
write(out,'****************************************************************************************')
write(out,'	Model averaging information')
write(out,' ')
outi = find(res('prob') > 0.01) //limit printing to models > 1% post prob
nmod = length(outi)
nvar = res('nvar')
 
namex=res('namex')
nnamex = size(namex,1)
maxnamex = max(length(res('namex')),1)
nbmod2prt=5-floor(maxnamex/20)
models=res('model')
probs=res('mprob')
visits=res('visit')
 
for i=1:ceil(nmod/nbmod2prt)
   n1=1+(i-1)*nbmod2prt
   n2=min(i*nbmod2prt,nmod)
   mat2print=[namex models(:,n1:n2) ; 'prob. (%)' probs(n1:n2)' ; '# of visists' visits(n1:n2)']
   mat2print=['models' 'model '+string(n1:n2) ; mat2print]
 
   printmat(mat2print,out)
 
end 			
 
write(out,' ')
write(out,'****************************************************************************************')
write(out,'	Posterior Estimates')
write(out,' ')
 
df =res('nobs')-res('nvar')
tstat = res('tstat')
for i=1:res('nvar')+1
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
mat2print = [' variable   ',' coeff.  ',' t-stat.   ',' p-value   ']
 
namex = res('namex')
exo = ['const';namex]
for i = 1:res('nvar')+1
	mat2print  = [mat2print ; string(exo(i)) string(res('beta')(i)) string(res('tstat')(i))...
										string(pvalue(i))]
end
printmat(mat2print,out)
 
printsep(out)
endfunction
