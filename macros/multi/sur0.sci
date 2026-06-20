function [beta0,resid,yhat,sigma,ixpomegam1x,ncoefeqs]=sur0(y0,X,crit,itmax)

[nobs,neqs]=size(y0)
[junk,ncoeffs]=size(X)
ncoefeqs=zeros(neqs,1)
for i=1:neqs
   Xi=X(1+(i-1)*nobs:i*nobs,:)
   ncoefeqs(i)=sum(sum(abs(Xi),'r') ~= 0)
end

y=y0(:)
convg=crit*2
// uses results from ols as starting values
beta0=ols0(y,X)
resid0=y-X*beta0
nbit=0

//if (convg <= crit | nbit >= itmax) then
//   pause
//end
while (convg > crit & nbit < itmax) then
   nbit=nbit+1
   sigma=zeros(neqs,neqs)
   resd=resid0 ./ (sqrt(nobs-ncoefeqs) .*. ones(nobs,1))
   rest=matrix(resd,nobs,neqs)
   sigma=real(rest'*rest)
   sqrtsigma=sigma^(-0.5) .*. eye(nobs,nobs)
   sqrtsigmax=sqrtsigma*X
   [bhat,ixpomegam1x]=ols0(sqrtsigma*y,sqrtsigmax)
   resid=y-X*bhat
   convg=sum(abs(bhat-beta0))
   beta0=bhat
   resid0=resid
end
 
resid=matrix(resid0,nobs,neqs)
yhat=y0-resid
tstat=bhat ./ sqrt(diag(ixpomegam1x))
pvalue=zeros(ncoeffs,1)
ds=diag(sigma)
ser=sqrt(ds)
sigu=ds .*(nobs-ncoefeqs)
corm=var2cor(sigma)
 
for i=1:ncoeffs
   pvalue(i)=(1-cdfnor("PQ",abs(tstat(i)),0,1))*2
end
 
// durbin-watson
dw=zeros(1,neqs)
for i=1:neqs
   ediff = resid(2:nobs,i)-resid(1:nobs-1,i)
   dw(i) = ediff'*ediff/sigu(i)
end
resn=matrix(resid,nobs,neqs)

endfunction
