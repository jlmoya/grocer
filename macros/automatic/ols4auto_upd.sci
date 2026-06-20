function res=ols4auto_upd(res,y,namexos,indx,val,p,ncomp,list_vararg)
 
// PURPOSE: supplement basic ols results stored in the input
// tlist (implicitely resulting from function ols2auto_part)
// ------------------------------------------------------------
// INPUT:
// * res = a results tlist, containing basic ols results
// * y = a (nobs x 1) vector of endogenous variables
// * namexos = a (k+l) vector of strings, the name of all
//   exogenous variables
// * r0 = a predefined tlist result whose needed fileds
//   already exist
// * indexos = the index of the x variables in the regression
// * val = a vector, the values of the specification tests
// * p = the corresponding p-values
// * varargin = an empty list of arguments (added to the input
//   of the function by confirmity with other functions that
//   can be called by the package automatic)
// ------------------------------------------------------------
// OUTPUT:
// * res = the results tlist, with full results
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012-2021
// http://grocer.toolbox.free.fr/grocer.html
 
 
nobs=res('nobs')
nvar=res('nvar')
sigu=res('sigu')
res('sige')=sigu/(nobs-nvar)
res('ser')=sqrt(res('sige'))
resid=res('resid')
ediff = resid(2:nobs)-resid(1:nobs-1)
res('dw')=ediff'*ediff/sigu
res('condindex')=bkwols(res('x'))
prescte=or(sum(abs(res('x')(2:$,:)-res('x')(1:$-1,:)),'r') == 0)
results('prescte') = prescte
 
if prescte & nvar ~=1 then
   df=nobs-nvar
   ym=y-y'*ones(nobs,1)/nobs
   rsqr2 = ym'*ym;
   // r-squared
   rsqr=1-sigu/rsqr2
   res('rsqr') =rsqr
   nobsm1=nobs-1
   nvarm1=nvar-1
   res('rbar') = 1-sigu/df/rsqr2*nobsm1
// rbar-squared
   f=rsqr/(1-rsqr)*df/(nvar-1)
   pvaluef=1-cdff("PQ",f,nvarm1,nobs-nvar)
   res('f') = f
   res('pvaluef') = pvaluef
else
   res('prescte')=%f
   if or(res(1) == 'rsqr') then
      res('rsqr')=%nan
      res('rbar')=%nan
      res('f')=%nan
      res('pvaluef')=%nan
   end
end
 
res('spec_test')=[val p]

if isempty(indx) then
   res('namex')=namexos([1:ncomp])
else
   res('namex')=namexos([1:ncomp ncomp+indx])
end
res('llike')=-0.5*nobs*(log(2*%pi)+log(sigu/nobs)+1)
res('aic')=log(sigu/nobs)+nvar*2/nobs
res('bic')=log(sigu/nobs)+nvar*log(res('nobs'))/res('nobs')
res('hq')=log(sigu/nobs)+nvar*2*log(log(res('nobs')))/res('nobs')
 
endfunction
