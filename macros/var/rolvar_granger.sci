function res=rolvar_granger(res_rolvar,causing,caused,noprint)
 
// PURPOSE: perform Granger (non-)causality tests for a
// rolling VAR
// ------------------------------------------------------------
// INPUT:
// * res_rolvar = a 'rolling var' results tlist
// * causing = a (j x 1) vector, the indexes of the causing
//   variables
// * caused = a (k x 1) vector, the indexes of the caused
//   variables
// * noprint = 'noprint' if the user does not to print the
//   results
// ------------------------------------------------------------
// OUTPUT:
// rvar = a results tlist with:
// * rvar('meth') = 'rolling var Granger causality'
// * rvar('rolvar res') = the input 'rolling var' results
//   tlist
// * rvar('causing') = the index vector of the supposed causing
//   variables
// * rvar('caused') = the index vector of the supposed caused
//   variables
// * rvar('chi2 stat') =  the vector of rolling Wald statistics
//   of non-causlity
// * rvar('chi2 pvalue') =  their p-values
// * rvar('Fisher stat') =  the vector of rolling statistics
//   of non-causlity inf Fisher form
// * rvar('Fisher pvalue') =  their p-values
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
 
nargin=argn(2)
if nargin < 4 then
   plt=%t
elseif noprint == 'noprint' then
   plt=%f
else
   plt=%t
end
meth=res_rolvar('meth')
namey=res_rolvar('namey')
if meth ~= 'rolling var' then
   error('rol_vargarnger applies to a rolling var tlist result')
end
 
caused=caused(:)'
causing=causing(:)'
ncausing=size(causing,2)
ncaused=size(caused,2)
 
if typeof(causing)  == 'string' then
   aux_causing=causing
   causing=zeros(1,ncausing)
   for i=1:size(causing,'*')
      causing(i)=find(namey == aux_causing(i))
   end
end
 
if typeof(caused)  == 'string' then
   aux_caused=caused
   caused=zeros(1,ncaused)
   for i=1:size(caused,'*')
      caused(i)=find(namey == aux_caused(i))
   end
end
 
coeffs=res_rolvar('beta')
nestim=size(coeffs,1)
nlag=res_rolvar('nlag')
nvar=res_rolvar('nvar')
vcovar=res_rolvar('vcovar')
ncoeffs=nvar*nlag+res_rolvar('nx')
ndl=res_rolvar('nper')-ncoeffs
 
ind_causing=causing .*. ones(1,nlag)+ ones(1,ncausing).*. ([0:nlag-1]*nvar)
ind_varbeta=((caused-1)*ncoeffs) .*. ones(1,ncausing*nlag)+ones(1,ncaused) .*. ind_causing
 
granger_chi2=zeros(nestim,1)
granger_pchi2=zeros(nestim,1)
granger_Fisher=zeros(nestim,1)
granger_pFisher=zeros(nestim,1)
sumbet=zeros(nestim,1)
 
for estim=1:nestim
   coeffs_estim=squeeze(coeffs(estim,:,:))
   bet=coeffs_estim(ind_causing,caused)
   bet=bet(:)
   sumbet(estim)=sum(bet)
   vcovar_estim=squeeze(vcovar(estim,:,:))
   varbeta=vcovar_estim(ind_varbeta,ind_varbeta)
   granger_chi2(estim)=bet'*inv(varbeta)*bet
   granger_pchi2(estim)=1-cdfchi("PQ",granger_chi2(estim),nlag*ncaused*ncausing)
   granger_Fisher(estim)=granger_chi2(estim)/(nlag*ncaused*ncausing)
   granger_pFisher(estim)=1-cdff("PQ",granger_Fisher(estim),nlag*ncaused*ncausing,ndl)
end
 
res=tlist(['results';'meth';'rolvar res';'causing';'caused';'chi2 stat';'chi2 pvalue';...
'Fisher stat';'Fisher pvalue';'sum betas'],...
'rolling var Granger causality',res_rolvar,causing,caused,granger_chi2,granger_pchi2,...
granger_Fisher,granger_pFisher,sumbet)
 
if plt then
   plt_rol_vargranger(res,'Fisher pvalue')
end
 
endfunction
