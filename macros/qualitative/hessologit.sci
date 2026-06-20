function res=hessologit(res)
 
// PURPOSE: evaluate ordered logit hessian, variances and
// standard errors and store them in the logit results tlist
// ------------------------------------------------------------
// INPUT:
// * res = a ologit results tlist
// ------------------------------------------------------------
// OUTPUT:
// * res = a ologit results tlist
//-----------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
y=res('y')
x=res('x')
nobs=size(y,1)
// find the values taken by y
valy=unique(y)
nvaly=size(valy,1)
 
// cut the parameters between those relative to the exogenous
// variables and those relative to the cut-offs
param=res('beta')
nparam=size(param,1)
nb=nparam-nvaly+1
nc=nvaly-1
b=param(1:nb)
c=param(nb+1:nparam)
 
ynew=zeros(nobs,nvaly)
for i=1:nvaly
   ynew(:,i)=(y == valy(i))
end
 
F=zeros(nobs,nvaly+1)
F(:,nvaly+1)=1
cminusxb=(ones(nobs,1) .*. c') - (x*b .*. ones(1,nvaly-1))
 
epxm_cminusxb=exp(-cminusxb)
 
H=zeros(nparam,nparam)
 
F(:,2:nvaly)=ones(nobs,nvaly-1) ./ (1+epxm_cminusxb)
f=F .* (1-F)
 
for i=1:nobs
   H(1:nb,1:nb)=H(1:nb,1:nb)-x(i,:)'*x(i,:)...
   *sum((f(i,2:nvaly+1)-f(i,1:nvaly)).^2 ./ (F(i,2:nvaly+1)-F(i,1:nvaly)))
   H(1:nb,nb+1:nparam)=H(1:nb,nb+1:nparam)+x(i,:)'*(f(i,2:nvaly)...
   .*((f(i,2:nvaly)-f(i,1:nvaly-1))./(F(i,2:nvaly)-F(i,1:nvaly-1))...
   -(f(i,3:nvaly+1)-f(i,2:nvaly))./(F(i,3:nvaly+1)-F(i,2:nvaly))))
   for j=1:nc
      H(nb+j,nb+j)=H(nb+j,nb+j)-f(i,j+1).^2 .*(1 ./ (F(i,j+2)-F(i,j+1))+...
                  1 ./ (F(i,j+1)-F(i,j)))
   end
   for j=1:nc-1
      H(nb+j,nb+j+1)=H(nb+j,nb+j+1)+f(i,j+1)*f(i,j+2)/(F(i,j+2)-F(i,j+1))
   end
end
 
for j=1:nc-1
   H(nb+j+1,nb+j)=H(nb+j,nb+j+1)
end
 
H(nb+1:nparam,1:nb)=H(1:nb,nb+1:nparam)'
 
covb=-inv(H)
stdb = sqrt(diag(covb));
tstat=param ./ stdb
 
df=nobs-nparam
pvalue=ones(nparam,1)
for i=1:nparam
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
res(1)($+1)='covb'
res(1)($+1)='tstat'
res(1)($+1)='pvalue'
res('covb')=-inv(H)
res('tstat')=tstat
res('pvalue')=pvalue
 
endfunction
 
