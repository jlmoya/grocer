function results=ppooledhac4auto_part(results,y,x,z,ncomp,indx,list_vararg)
 
// PURPOSE: performs Fixed Effects Estimation for Panel Data
// (for balanced or unbalanced data) using the within-groups
//     estimation procedure.
// ------------------------------------------------------------
// INPUT:
// * y = a (nobs x neqs) matrix of all of the individual's
//   observations vertically concatenated. This matrix must
//   include in the first column the dependent variable, the
//   independent variables must follow accordingly.
// * index = index vector that identifies each observation with
//   an individual
//   e.g. 1  (first 2 observations  for individual # 1)
//        1
//        2  (next  1 observation   for individual # 2)
//        3  (next  3 observations  for individual # 3)
//        3
//        3
// * z = optional matrix of exogenous variables, dummy
//   variables.
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . rpanel('meth')='panel with fixed effects'
//   . rpanel('y')     = y data vector
//   . rpanel('x')     = x data matrix
//   . rpanel('nobs')  = nobs
//   . rpanel('nvar')  = nvars
//   . rpanel('beta')  = bhat
//   . rpanel('yhat')  = yhat
//   . rpanel('resid') = residuals
//   . rpanel('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rpanel('sige')  = estimated variance of the residuals
//   . rpanel('sigu')  = sum of squared residuals
//   . rpanel('ser')  = standard error of the regression
//   . rpanel('tstat') = t-stats
//   . rpanel('pvalue') = pvalue of the betas
//   . rpanel('condindex') = multicolinearity cond index
//   . rpanel('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rpanel('lliked') = log-likelihood
//   . rpanel('rsqr')  = rsquared
//   . rpanel('rbar')  = rbar-squared
//   . rpanel('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rpanel('pvaluef') = its significance level
// ------------------------------------------------------------
// Copyright: Eric Dubois (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Translated and adpated from Matlab programs
// Written by:
// Carlos Alberto Castro
// National Planning Department
// Bogota, Colombia
// Email: ccastro@dnp.gov.co
 
index=list_vararg(2)
uniq=unique(index)
typvcv=list_vararg(3)
win=list_vararg(4)
 
xpath=[z x]
[nobs,nvar]=size(xpath)
 
[q,r]= qr(xpath,'e')
ir=inv(r)
bet=ir*q'*y
 
yhat = xpath*bet
resid = y-yhat
 
nindiv=results('nb. indiv')
 
Ti=[];
for i=1:nindiv
  id_i=find(index==uniq(i));
  Ti=[Ti;size(id_i,'*')];
end
 
 
//"clustered" covariance matrix of Arellano (1987)
if typvcv==1 then
  xx=0;
  xuux=0;
  for i=1:nindiv
    id_i=find(index==uniq(i));
    eps_i=resid(id_i);
    x_i=x(id_i,:);
    xx=xx+x_i'*x_i;
    xuux=xuux+x_i'*eps_i*eps_i'*x_i;
  end
  vcovar=inv(xx)*xuux*inv(xx);
elseif typvcv==2 then
  if length(unique(Ti))==1;
    h=(resid*ones(1,nx).*x);
    // order the data in time
    H=[];
    for j=1:nx
      for i=1:nindiv
        id_i=find(index==uniq(i));
        H=[H,h(id_i,j)];
      end
    end
 
 
    idh=vec(matrix(1:(nx*nindiv),nindiv,nx)')';
    oh=matrix(H(:),nobs,nx);
    oh=matrix(oh,nobs/nindiv,nx*nindiv);
    oh=matrix(vec(oh(:,idh)),nx*nobs/nindiv,nindiv);
    oh=matrix(sum(oh,2),nobs/nindiv,nx);
 
 
    if length(win)==0
      write(%io(2),'      Andrews automatic lag truncation selection:','(a)');
      num=zeros(nx,1);den=num;
      for j=1:nx
        oh_dm=oh(:,j)-mean(oh(:,j))
        tmpo=ols1(oh_dm(2:$),oh_dm(1:$-1));
        phi=tmpo('beta');
        sigma=sqrt(tmpo('sige'));
        num(j)=4*phi^2*sigma^4/((1-phi)^6*(1+phi)^2);
        den(j)=sigma^4/(1-phi)^4;
      end
      al=sum(num)/sum(den);
      win=1.1447*(al*Ti(1))^(1/3);
      write(%io(2),' estimated bandwidth: '+string(win),'(a)');
    else
      win=win+1; // bartlett kernel = 1-j/(win+1)
    end
 
 
    omeg=oh'*oh;
    i=1;
    while abs(i/win)<=1 then
      omeg_l=oh(1:($-i),:)'*oh((i+1):$,:);
      omeg=omeg+(1-abs(i/win))*(omeg_l+omeg_l');
      i=i+1;
    end
    vcovar=inv(x'*x)*omeg*inv(x'*x);
  else
    error('Newey-West type variance matrix doesn''t work with unbalanced panel');
  end
end
 
sigu =resid'*resid
vcovar=sigu/(nobs-nvar)*ir*ir'
tstat = bet ./ sqrt(diag(vcovar))
 
pvalue=ones(nvar,1)
for i=1:nvar
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),nobs-nvar))*2
end
 
results('x') = xpath
results('nvar')  = nvar
results('yhat')  = yhat
results('beta')  = bet
results('tstat') = tstat
results('pvalue') = pvalue
results('resid') = resid
results('vcovar') = vcovar
results('sigu') = sigu
 
endfunction
