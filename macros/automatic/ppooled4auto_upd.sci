function res=ppooled4auto_upd(res,y,namexos,indx,val,p,ncomp,list_vararg)
 
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
// Copyright: Eric Dubois 2012-2013
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_nameid=list_vararg(1)
 
condindex=bkwols(res('x'))
nobs=res('nobs')
sigu=res('sigu')
nexo=res('nvar')
 
llike=-0.5*nobs*(log(2*%pi)+log(res('sigu')/nobs)+1)
 
indcte=search_cte(res('x'))
prescte=~isempty(indcte)
 
if prescte  then
// R² and Rbar² make sense
   rsqr1 = sigu;
   ym=y-mean0(y)
   rsqr2 = ym'*ym;
   // r-squared
   rsqr=1-rsqr1/rsqr2
   nobsm1=nobs-1
   nvarm1=nexo-1
   df=nobs-nexo
   rbar = 1-rsqr1/df/rsqr2*nobsm1
   // rbar-squared
   if rsqr ~= 1 then
      f=rsqr/(1-rsqr)*df/(nexo-1)
   else
      warning('rsqr = 1: your exogenous variables are exactly colinear')
      f=%inf
   end
   pvaluef=1-cdff("PQ",f,nvarm1,nobs-nexo)
   res('rsqr')=rsqr
   res('rbar')=rbar
   res('f')=f
   res('pvaluef')=pvaluef
end
 
if isempty(indx) then
   res('namex')=namexos([1:size(z,2)])
else
   res('namex')=namexos([1:size(z,2) size(z,2)+indx])
end
res('condindex')=condindex
res('llike')=llike
res('prescte')=prescte
 
endfunction
