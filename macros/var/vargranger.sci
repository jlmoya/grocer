function res=vargranger(rvar,causing,caused,noprint)
 
// PURPOSE: perform Granger (non-)causality tests for a VAR
// ------------------------------------------------------------
// INPUT:
// * rvar = a 'var' results tlist
// * causing = a (j x 1) vector, the indexes of the causing
//   variables
// * caused = a (k x 1) vector, the indexes of the caused
//   variables
// * noprint = 'noprint' if the user does not to print the
//   results
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// * res('meth') = 'var Granger causality'
// * res('rvar res') = the input 'var' results tlist
// * res('causing') = the index vector of the supposed causing
//   variables
// * res('caused') = the index vector of the supposed caused
//   variables
// * res('chistat') =  the vector of Wald statistics for
//   non-causlity
// * res('chi_pvalue') =  their p-values
// * res('chi_df') =  the degrees of freedom of the chi2
// * res('f') =  the Fisher statistics for non-causlity
// * res('dfnum') =  the numerator degrees of freedom
// * res('dfden') =  the denominator degrees of freedom
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
 
 
nargin=argn(2)
if nargin < 4 then
   prt=%t
elseif noprint == 'noprint' then
   prt=%f
else
   prt=%t
end
meth=rvar('meth')
namey=rvar('namey')
if meth ~= 'var' then
   error('vargranger applies to a VAR tlist result')
end
 
caused=caused(:)'
causing=causing(:)'
ncausing=size(causing,2)
ncaused=size(caused,2)
 
if typeof(causing)  == 'string' then
   aux_causing=causing
   causing=zeros(1,ncausing)
   for i=1:size(causing,1)
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
 
coeffs=rvar('beta')
nlag=rvar('nlag')
nvar=rvar('neqs')
vcovar=rvar('vcovar')
ncoeffs=nvar*nlag+rvar('nx')
ndl=(rvar('nobs')-ncoeffs)*ncaused
 
ind_causing=causing .*. ones(1,nlag)+ ones(1,ncausing).*. ([0:nlag-1]*nvar)
ind_varbeta=((caused-1)*ncoeffs) .*. ones(1,ncausing*nlag)+ones(1,ncaused) .*. ind_causing
 
bet=coeffs(ind_causing,caused)
bet=bet(:)
varbeta=vcovar(ind_varbeta,ind_varbeta)
granger_chi2=bet'*inv(varbeta)*bet
granger_pchi2=1-cdfchi("PQ",granger_chi2,nlag*ncaused*ncausing)
granger_Fisher=granger_chi2/(nlag*ncaused*ncausing)
granger_pFisher=1-cdff("PQ",granger_Fisher,nlag*ncaused*ncausing,ndl)
 
res=tlist(['results';'meth';'rvar res';'causing';'caused';'chistat';'chi_pvalue';...
'chi_df';'f';'f_pvalue';'dfnum';'dfden'],...
'var Granger causality',rvar,causing,caused,granger_chi2,granger_pchi2,...
nlag*ncaused*ncausing,granger_Fisher,granger_pFisher,nlag*ncaused*ncausing,ndl)
 
if prt then
   prt_vargranger(res)
end
 
endfunction
