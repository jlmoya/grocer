function [zt,dummies]=indicator_saturation1(y,x,alpha,func)
    

[nargout,nargin]=argn(0)

if nargin < 4 then
   func=ols1
end
[nobs,nvar]=size(x)
cut=2
while(nobs/cut <nvar) then
    cut=cut+1
end

dummies=[]
zt=[]
for nreg=1:cut
    ind_dummies=floor((nobs*(nreg-1))/cut+1):floor((nobs*nreg)/cut)  
    zreg=zeros(nobs,size(ind_dummies,2))
    first_nonincluded=ind_dummies(1)-1
    for i=ind_dummies
       zreg(i,i-first_nonincluded)=1
    end
    z=[x, zreg ]
    r=func(y,z)
    pvalues=r('pvalue')
    pvalues_dummies=pvalues(nvar+1:$)
    dummies_signif=find(pvalues_dummies <= alpha)
    dummies=[dummies ind_dummies(dummies_signif)]
    zt=[zt , zreg(:,dummies_signif)]
end

if size(zt,2) >= nobs-nvar then
   error('too many dummies')
end
r=ols1(y,[x zt])
pvalues=r('pvalue')
pvalues_dummies=pvalues(nvar+1:$)
dummies_signif=find(pvalues_dummies <= alpha)
dummies=dummies(dummies_signif)
zt=zt(:,dummies_signif)

endfunction
