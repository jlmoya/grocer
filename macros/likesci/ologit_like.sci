function [llike,gra,F]=ologit_like(param,y,x)
 
// PURPOSE: evaluate logit log-likelihood and first
// order derivatives
//-----------------------------------------------------
// INPUT:
// * param = parameter vector (k x 1)
// * y = dependent variable vector (n x 1)
// * x = explanatory variables matrix (n x m)
//-----------------------------------------------------
// OUTPUT:
// * llike = log-likelihood
// * gra = gradient of the log-likelihood
// * F = (k+1 x 1) vector of probabilities at cut-offs
//-----------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
nobs=size(y,1)
// find the values taken by y
valy=unique(y)
nvaly=size(valy,1)
// cut the parameters between those relative to the exogenous
// variables and those relative to the cut-offs
nparam=size(param,1)
nb=nparam-nvaly+1
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
 
P=ones(nobs,nvaly-1) ./ (1+epxm_cminusxb)
F(:,2:nvaly)=P
f=F(:,2:nvaly) .* (1-F(:,2:nvaly))
 
llike=sum(ynew .* log(F(:,2:nvaly+1)-F(:,1:nvaly)))
gra=zeros(nparam,1)
db=zeros(nobs,nvaly)
 
db(:,1)=-f(:,1)./ F(:,2)
db(:,2:nvaly-1)=-(f(:,2:nvaly-1)  - f(:,1:nvaly-2)) ./ (F(:,3:nvaly) - F(:,2:nvaly-1))
db(:,nvaly)=f(:,nvaly-1)  ./ (1-F(:,nvaly))
gra(1:nb)=x'*sum(db .* ynew,'c')
gra(nb+1)=-ynew(:,1)'*db(:,1)-ynew(:,2)'*(f(:,1) ./ (F(:,3) - F(:,2)))
gra(nb+2:nparam-1,:)=ynew(:,2:nvaly-2)'*(f(:,2:nvaly-2) ./ (F(:,3:nvaly-1) - F(:,2:nvaly-2))) ...
- ynew(:,3:nvaly-1)'*(f(:,2:nvaly-2) ./ (F(:,4:nvaly) - F(:,3:nvaly-1)))
gra(nparam)=-ynew(:,nvaly)'*db(:,nvaly) + ynew(:,nvaly-1)'*(f(:,nvaly-1) ./ (F(:,nvaly) - F(:,nvaly-1)))
 
endfunction
 
