function [results]=threesls(varargin)
 
// PURPOSE: computes Three-Stage Least-squares Regression
// ------------------------------------------------------------
// INPUT:
// * varargin = equations of the following form:
//  'vary=coef1*varx1+...+coefi*varxi'
//   where:
//   - coefi = the name of a coefficient
//   - varxi = the name of a variable
// * 'coef=coef1;coef2;...coefn' where coef1,...,coefn are the
//   names of the coefficients in the system
//   (optional; default: 'coef=a1;...,an)
// * 'endo =[endo1;...;endon]' where endo1,...,endon are the
//   names of the endogenous variables
//   (optional; necessary if the names of the endogenous
//   variables in the rhs of the equations are not the same as
//   those of the lhs; default: the names of all the lhs sides
//   of the equations)
// * 'noprint' if you do not want to print the results
// * 'dropna' if the user wants to remove the NA values
//     from the data
// ------------------------------------------------------------
// OUTPUT:
// results = a structure tlist with
// - results('meth')  = 'threesls'
// - results('namecoef')  = the matrix of the names of the
//   coefficients
// - results('riv1'),...,results('rivn) = the results of the iv
//   estimation for each equation
// ------------------------------------------------------------
// Copyright Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_neqs=length(varargin)
 
// set defaults
itmax=100
crit=1e-4
grocer_defcoef=%f
grocer_prt=%t
grocer_dropna=%f
 
// find if the user has given options, store them and keep the
// equations in the varargin list
for grocer_i=grocer_neqs:-1:1
   grocer_eq=varargin(grocer_i)
   if grocer_eq == 'noprint' then
      grocer_prt=%f
      grocer_neqs=grocer_neqs-1
      varargin(grocer_i)=null()
   elseif grocer_eq == 'dropna' then
      grocer_dropna=%t
      grocer_neqs=grocer_neqs-1
      varargin(grocer_i)=null()
   else
      grocer_indequal=strindex(varargin(grocer_i),'=')
      if size(grocer_indequal,2) ~= 1 then
         error('bad expression for',varargin(grocer_i))
      end
      if (part(grocer_eq,1:6) == 'itmax='...
         | (part(varargin(grocer_i),1:5) == 'crit=')) then
         execstr(varargin(grocer_i))
         varargin(grocer_i)=null()
         grocer_neqs=grocer_neqs-1
      else
         if part(grocer_eq,1:5) == 'coef=' then
            grocer_coef=str2vec(grocer_eq,',',';')
            grocer_ncoef=size(grocer_coef,1)
            grocer_defcoef=%t
            varargin(grocer_i)=null()
            grocer_neqs=grocer_neqs-1
         end
         if part(grocer_eq,1:5) == 'endo=' then
            grocer_endo=str2vec(grocer_eq)
            varargin(grocer_i)=null()
            grocer_neqs=grocer_neqs-1
         end
      end
   end
end
 
// if the user has not provided the names of the coefficients
// determine them
grocer_speccarb=['+' ; '(' ; '-' ; '*']
grocer_speccara=['+' ; '-' ; '*' ; '/' ; ')']
if ~grocer_defcoef then
   grocer_coef=defaultcoef('a',grocer_speccarb,grocer_speccara,varargin(:))
end
 
grocer_namey=emptystr(grocer_neqs,1)
grocer_ncoef=list()
grocer_lexo=list()
for grocer_i=1:grocer_neqs
   [grocer_nyi,grocer_ncoefi,grocer_lexoi]=...
   eqlist(varargin(grocer_i),grocer_coef)
   grocer_namey(grocer_i)=grocer_nyi
   grocer_ncoef($+1)=grocer_ncoefi
   grocer_lexo($+1)=grocer_lexoi
end
grocer_lvar=lstcat(list(grocer_namey),grocer_lexo)
 
execstr('un=1+0*'+grocer_nyi)
[grocer_z,grocer_namez,grocer_prests,grocer_boundsvarb,grocer_nonna]=...
explone(grocer_lvar,[],'exogenous',%t,grocer_dropna)
 
if ~exists('grocer_endo','local') then
   grocer_endo=grocer_namey
end
 
[xall,lx1,ly1,endoeq,nameinst,lindx1,lindy1]=exploeqs(grocer_neqs,..
grocer_lexo,grocer_endo,grocer_z,grocer_namez)
 
results=tlist(['results';'meth';'namecoef'],...
'threesls',grocer_coef)
 
nobs=size(un,1)
X=zeros(nobs*grocer_neqs,length(lx1)+length(ly1))
Y=zeros(nobs*grocer_neqs,1)
resid=zeros(nobs,grocer_neqs)
nexo=1
for i=1:grocer_neqs
   riv=iv1(grocer_z(:,i),ly1(i),lx1(i),xall)
   resid(:,i)=riv('resid')
   Y(nobs*(i-1)+1:nobs*i)=riv('y')
   execstr('riv'+string(i)+'=riv')
   X(nobs*(i-1)+1:nobs*i,nexo:nexo+size(riv('x'),2)-1)=[ly1(i) lx1(i)]
   nexo=nexo+size(riv('x'),2)
end
 
sigma=resid'*resid/nobs
iomega=inv(sigma).*.(xall*inv(xall'*xall)*xall')
ixpx=inv(X'*iomega*X)
b3sls=ixpx*X'*iomega*Y
t3sls=b3sls./diag(ixpx)
yhat=X*b3sls
resid=Y-yhat
nexo=0
 
for i=1:grocer_neqs
   execstr('riv=riv'+string(i))
   riv('meth')='threesls'
   riv('yhat')=yhat(nobs*(i-1)+1:nobs*i)
   resi=resid(nobs*(i-1)+1:nobs*i)
   riv('resid')=resi
   lind=lindy1(i)
   ny=size(lind,2)
   for j=1:ny
      riv('beta')(lind(j))=b3sls(nexo+j)
      riv('tstat')(lind(j))=t3sls(nexo+j)
   end
   lind=lindx1(i)
   nx=size(lind,2)
   for j=1:nx
      riv('beta')(lind(j))=b3sls(nexo+ny+j)
      riv('tstat')(lind(j))=t3sls(nexo+ny+j)
   end
   df=nobs-riv('nvar')
   for j=1:riv('nvar')
      pvalue(j)=(1-cdft("PQ",abs(riv('tstat')(j)),df))*2
   end
   sigu=resi'*resi
   riv('sigu')=sigu
   riv('sige')=sigu/df
// durbin-watson
   ediff = resi(2:nobs)-resi(1:nobs-1)
   riv('dw') = ediff'*ediff/sigu
   nexo=nexo+nx+ny
   // saves the names, the bounds if the regression involves ts
   riv(1)($+1) = 'prests'
   riv(1)($+1) = 'namex'
   riv(1)($+1) = 'nameendo'
   riv(1)($+1) = 'namey'
   riv(1)($+1) = 'nameinst'
   riv(1)($+1) = 'dropna'
   riv('prests')=grocer_prests
   riv('namex')=grocer_lexo(i)
   riv('nameendo')=endoeq(i)
   riv('namey')=grocer_namey(i)
   riv('nameinst')=nameinst
   riv('dropna')=grocer_dropna
 
   if grocer_prests then
      riv(1)($+1) = 'bounds'
      riv('bounds')=grocer_boundsvarb
   end
   if grocer_dropna then
      riv(1)($+1)='nonna'
      riv('nonna')=nonna
   end
 
   results(1)($+1)='riv'+string(i)
   results($+1)=riv
   if grocer_prt then
      execstr('prt_iv(results(''riv'+string(i)+'''))')
   end
end
 
endfunction
