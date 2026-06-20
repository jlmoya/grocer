function [std,var]=se_param(param,param_c,nvar,hdelta);
 
// PURPOSE: Calculate the standard deviation of a turning point
// estimation
// ------------------------------------------------------------
// INPUT:
// * param = a (nparam x 1) vector of parameters coming from the
//   optimisation of the log-kikelihood
// * param_c = a (k x 1) vector of indexes relative to the
//   parameters that have been set at the bounds of the
//   estimation set
// ------------------------------------------------------------
// OUTPUT:
// * std = the standard deviation of the final parameters (with
// %nan values for parameters at the bounds)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated from a Gauss programm by J. Bardaji and F. Tallet
 
h=-hessian0(ms_quali_llike,param,hdelta)
h(param_c,:)=[]
h(:,param_c)=[]
param_nc=[1:size(param,1)]
param_nc(param_c)=[]
std=%nan*param
 
select nblatent
 
case 2 then
 
   jac=zeros(4+2*nvar,4+2*nvar)
   for i=1:nbparam
      jac(i,i)=exp(param(i))/(1+exp(param(i)))^2
   end
   jac(param_c,:)=[]
   jac(:,param_c)=[]
   var=jac*inv(h)*jac'
   std(param_nc)=sqrt(diag(var))
 
else
 
   var=inv(h)
   std(param_nc)=sqrt(diag(var))
 
end
 
endfunction
 
