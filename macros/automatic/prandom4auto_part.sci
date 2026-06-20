function [results]=prandom4auto_part(results,y,x,z,ncomp,indx,list_vararg)
 
// PURPOSE: the functions performing ordinary least squares in
// an automatic regression with partial results: x et y are
// supposed to be respectively a matrix, and a vector, a result
// structure already exists and can be filled
// ------------------------------------------------------------
// INPUT:
// * results: an existing tlist of regression results
// * y = dependent variable vector (nobs x 1)
// * x = original set of independent variables matrix
//       (nobs x nexo)
// * z = set of variables that are constrained to be in
// * varargin = an empty list of arguments (added to the input
//   of the function by confirmity with other functions that
//   can be called by the package automatic)
// ------------------------------------------------------------
// OUTPUT:
// a tlist with:
//        results('meth')  = 'ols'
//        results('y')     = y data vector
//        results('x')     = x data matrix
//        results('nobs')  = number of observations
//        results('nexo')  = number of exogenous variables
//        results('yhat')  = yhat
//        results('beta')  = bhat
//        results('tstat') = t-stats
//        results('pvalue') = corresponding pvalue
//        results('resid') = residuals
//        results('vcovar') = vcovar
//        results('sigu') = sigu
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013-2014
// http://grocer.toolbox.free.fr/grocer.html
 
glsmeth=list_vararg(1)
indiv=list_vararg(2)
nameindiv=list_vararg(3)
 
[nobs,nz] = size(z);
[nobs,nx] = size(x);
 
// creation of the id matrix using the vector indiv
uniq=unique(indiv)
 
nindiv = size(uniq,1);
nexo=nx+nindiv+nz
const=zeros(nobs,nindiv)
 
// transformation of all the variables used
// the variables are expressed as deviations from the individual means
// so calculate first the individual means
xm=0*x
zm=0*z
ym=0*y
ym0=zeros(nindiv,1)
xm0=zeros(nindiv,nx)
zm0=zeros(nindiv,nz)
ntypes=ones(nindiv,1)
list_types=list()
 
for i = 1:nindiv
 
    id_i=find(indiv == uniq(i))
    list_types(i)=id_i
    ntypei=size(id_i,2)
    ntypes(i)=ntypei
    yi=y(id_i)
    meany=mean0(yi)
    ym(id_i) = meany
    ym0(i) = meany
    xi = x(id_i,:)
    meanxi=mean0(xi,1)
    xm(id_i,:) = ones(ntypei,1) .*. meanxi
    xm0(i,:)=meanxi
    if nz then
       zi = z(id_i,:)
       meanzi=mean0(zi,1)
       zm(id_i,:) = ones(ntypei,1) .*. meanzi
       zm0(i,:)=meanzi
    end
    const(id_i,i)=1
 
end
 
alfa=ones(nindiv,1)
 
if glsmeth == 'wallace' then
// pooled estimation
   betap=ols0(y,[x z])
   residp=y-[x z]*betap
   sige1=0
   resid_dm=residp
   for i=1:nindiv
      id_i=list_types(i)
      resid1m=mean0(residp(id_i))
      sige1=sige1+resid1m^2*ntypes(i)/(nindiv-nx-nz)
      resid_dm(id_i)=residp(id_i)-resid1m
   end
   sige2=resid_dm'*resid_dm/(nobs-nindiv)
 
// run OLS to obtain within estimated variance
 
else
// within estimation
   xmatw=[x-xm z-zm]
   yw=y-ym
   betaw=ols0(yw,xmatw)
   residw=yw-xmatw*betaw
   siguw = residw'*residw
   sige2 = siguw/(nobs-nindiv-nx-nz)
 
   select glsmeth
 
   case 'swamy' then
   // Between estimation
      indepm0 = [xm0 zm0 ones(nindiv,1)];
      betam = ols0(ym0,indepm0);
      residm = ym0-indepm0*betam
      sige1=residm'*residm/(nindiv-nx-nz-1)
 
   case 'amemiya' then
      iintc = ym0-xm0*betaw
      for i=1:nindiv
         id_i=list_types(i)
         residm= mean0(residw(id_i))+iintc(i)-mean0(iintc)
         sige1=sige2+residm'*residm/(nindiv-nx-nz)
      end
   end
 
end
 
if glsmeth ~= 'nerlove' then
   for i = 1:nindiv
      alfa(i) = 1-sqrt(sige2/ntypes(i)/sige1);
   end
   if min(alfa) < 0 then
      warning('method '+meth+' leads to a negative variance: switching to Nerlove''s method')
      meth='nerlove'
   end
else
   iintc = ym0-xm0*betaw
   sige1=mean0(ntypes)*sum((iintc-mean0(iintc)).^2)/(nindiv-1)+sige2
   for i = 1:nindiv
      alfa(i) = 1-sqrt(sige2/ntypes(i)/sige1);
   end
end
 
// transformation of all the variables used
// the variables are expressed as weighted deviations from the individual means
// taking into account the groupwise heteroscedasticity
 
ytr=y
xtr=x
ztr=z
llike=-nobs/2*log(2*%pi)-nobs/2-0.5*(nobs-nindiv)*log(sige2)-0.5*nindiv*log(sige1)
for i = 1:nindiv
 
    llike=llike-0.5*log(ntypes(i))
    id_i=list_types(i)
    ones_i=ones(size(id_i,2),1)
    ytr(id_i) = y(id_i)-alfa(i)*ym0(i);
    xtr(id_i,:) = x(id_i,:)- (ones_i .*. alfa(i)*xm0(i,:));
    ztr(id_i,:) = z(id_i,:)- (ones_i .*. alfa(i)*zm0(i,:));
 
end
 
const = ones(nobs,1)-max(alfa)
xmatr=[ const ztr xtr]
 
// run OLS
 
//res = ols2(ytr,xmatr);
[q,r]= qr(xmatr,'e')
ir=inv(r)
bet=ir*q'*ytr
 
yhat = xmatr*bet
resid = ytr-yhat
sigu =resid'*resid
vcovar=sigu/(nobs-nexo)*ir*ir'
tstat = bet ./ sqrt(diag(vcovar))
 
pvalue=ones(nx+nz+1,1)
for i=1:nx+nz+1
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),nobs-nexo))*2
end
resdo = y-[ones(nobs,1) z x]*bet;
 
// individual intercepts
 
for i = 1:nindiv
   id_i=list_types(i)
   iintc(i)= (sige1-sige2/mean0(ntypes))/(ntypes(i)*sige1)*sum(resdo(id_i));
end
 
 
// update tlist results
results('x') = xmatr
results('nvar')  = nx+nz+1
results('yhat')  = yhat
results('beta')  = bet
results('tstat') = tstat
results('pvalue') = pvalue
results('resid') = resid
results('vcovar') = vcovar
results('sigu') = sigu
results('llike') = llike
results('res0')=resdo
results('alfa')=alfa
results('individual')=indiv
results('random effects')=iintc
 
endfunction
