function res=var4auto_upd(res,y,namexos,indx,val,p,ncomp,list_vararg)
 
// PURPOSE: supplement basic ols results stored in the input
// tlist (implicitely resulting from function ols2auto_part)
// ------------------------------------------------------------
// INPUT:
// * res = a results tlist, containing baisc ols results
// * y = a (nobs x 1) vector of endogenous variables
// * namexos = a (k+l) vector of strings, the name of all
//   exogenous variables
// * indx = the index of the x variables in the regression
// * val = a vector, the values of the specification tests
// * p = the corresponding p-values
// * ncomp = the number of compulsory exogenous variables
// * varargin = an empty list of arguments (added to the input
//   of the function by confirmity with other functions that
//   can be called by the package automatic)
// ------------------------------------------------------------
// OUTPUT:
// * res = the results tlist, with full results
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013
// http://grocer.toolbox.free.fr/grocer.html
 
 
neqs=res('neqs')
nobs=res('nobs')
resid=res('resid')
ncomp=res('ncomp')*neqs
x=res('x')
ds=diag(res('sigma'))
sigu=ds .* (res('nobs')-res('nvar'))
// durbin-watson
dw=zeros(1,neqs)
for i=1:neqs
   ediff = resid(2:nobs,i)-resid(1:nobs-1,i)
   dw(i) = ediff'*ediff/sigu(i)
end
 
res('ser')=sqrt(ds)
res('sigu')=sigu
res('dw')=dw
res('spec_test')=[val p]
res('namex')=namexos([1:ncomp ncomp+indx])
res('indx')=indx
ncoeffs=sum(res('nvar'))
res('aic')=res('llike')+ncoeffs*2/res('nobs')
res('bic')=res('llike')+ncoeffs*log(res('nobs'))/res('nobs')
res('hq')=res('llike')+ncoeffs*2*log(log(res('nobs')))/res('nobs')
 
endfunction
