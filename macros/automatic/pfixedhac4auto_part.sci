function results=pfixedhac4auto_part(results,y,x,z,ncomp,indx,list_vararg)
 
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
 
//****************************************************************************************
// NOTE: James P. LeSage provided corrections on the creation and use of the index
//       vector used to identify the individual's observations.
// and Eric Dubois added his own ones
//****************************************************************************************
 
[nargout,nargin]=argn(0)
[nobs,nz] = size(z);
[nobs,nx] = size(x);
 
index=list_vararg(2)
uniq=unique(index)
typvcv=list_vararg(3)
win=list_vararg(4)
 
nindiv = size(uniq,1);
nexo=nx+nindiv+nz
const=zeros(nobs,nindiv)
 
// transformation of all the variables used
// the variables are expressed as deviations from the individual means
// so calculate first the individual means
xm=0*x
zm=0*z
ym=0*y
xm0=zeros(nindiv,nx)
zm0=zeros(nindiv,nz)
ym0=zeros(nindiv,1)
ntypes=ones(nindiv,1)
 
for i = nindiv:-1:1
 
    id_i=find(index == uniq(i))
    ntypei=size(id_i,2)
    ntypes(i)=ntypei
    yi=y(id_i)
    meany=sum(yi)/ntypei
    ym(id_i) = meany
    ym0(i) = meany
    xi = x(id_i,:)
    meanxi=sum(xi,'r')/ntypei
    xm(id_i,:) = ones(ntypei,1) .*. meanxi
    xm0(i,:)=meanxi
    if nz then
       zi = z(id_i,:)
       meanzi=sum(zi,'r')/ntypei
       zm(id_i,:) = meanzi
       zm0(i,:)=meanzi
    end
    const(id_i,i)=1
 
end
 
xnew=[x-xm z-zm]
 
[xpxi,xpxixp]=invxpx(xnew)
bhat=xpxixp*y
yhat=ym+xnew*bhat
 
resid=y-ym-xnew*bhat
sigu=resid'*resid
sige=sigu/(nobs-nexo)
 
iintc = ym0-[xm0 zm0]*bhat
bhat=[iintc ; bhat]
 
//"clustered" covariance matrix of Arellano (1987)
vcovar=zeros(nexo,nexo)
adjt=ones(nexo,1);
df=(nobs-nexo)*ones(nexo,1);
 
if typvcv==1 then
  xx=0;
  xuux=0;
  for i=1:nindiv
    id_i=find(index==uniq(i));
    eps_i=resid(id_i);
    x_i=[x(id_i,:),z(id_i,:)];
    xx=xx+x_i'*x_i;
    xuux=xuux+x_i'*eps_i*eps_i'*x_i;
  end
  adjt(1:(nx+nz))=sqrt((nindiv-1)/nindiv);
  df(1:(nx+nz))=nindiv-1;
 
  vcovar(nindiv+1:nexo,nindiv+1:nexo)=inv(xx)*xuux*inv(xx);
 
 
elseif typvcv==2 then
  // Newey-West type variance matrix
  // see Arellano M. (2003) p. 19
  // the call to this function comes after a call to pfixed4auto_full
  // so there is no need to check that it is a balanced panel case
    W=xnew;
    nw=size(W,2);
    h=(resid*ones(1,nw).*W);
    // order the data in time
    H=[];
    for j=1:nw
      for i=1:nindiv
        id_i=find(index==uniq(i));
        H=[H,h(id_i,j)];
      end
    end
 
 
    idh=vec(matrix(1:nw*nindiv,nindiv,nw)')';
    oh=matrix(H(:),nobs,nw);
    oh=matrix(oh,nobs/nindiv,nw*nindiv);
    oh=matrix(vec(oh(:,idh)),nw*nobs/nindiv,nindiv);
    oh=matrix(sum(oh,2),nobs/nindiv,nw);
 
    if length(win)==0 then
      write(%io(2),'      Andrews automatic lag truncation selection:','(a)');
      num=zeros(nw,1);den=num;
      for j=1:nx
        oh_dm=oh(:,j)-mean(oh(:,j))
        tmpo=ols1(oh_dm(2:$),oh_dm(1:$-1));
        phi=tmpo('beta');
        sigma=sqrt(tmpo('sige'));
        num(j)=4*phi^2*sigma^4/((1-phi)^6*(1+phi)^2);
        den(j)=sigma^4/(1-phi)^4;
      end
      al=sum(num)/sum(den);
      win=1.1447*(al*ntypes(1))^(1/3);
      write(%io(2),'  estimated bandwidth: '+string(win),'(a)');
    else
      win=win+1 // bartlett kernel = 1-j/(win+1)
    end
 
 
    omeg=oh'*oh;
    i=1;
    while abs(i/win)<=1 then
      omeg_l=oh(1:($-i),:)'*oh((i+1):$,:);
      omeg=omeg+(1-abs(i/win))*(omeg_l+omeg_l');
      i=i+1;
    end
    vcovar(nindiv+1:nexo,nindiv+1:nexo)=inv(W'*W)*omeg*inv(W'*W);
 
end
 
// Variances of the fixed effects remain unchanged see Green (2000) p. 579
vcovar(1:nindiv,1:nindiv)=sige*([xm0 zm0]*xpxi*[xm0 zm0]'+diag(1 ./ ntypes))
vcovar(nindiv+1:nexo,1:nindiv)=-sige*xpxi*[xm0 zm0]'
vocvar(1:nindiv,nindiv+1:nexo)=vcovar(nindiv+1:nexo,1:nindiv)'
 
ser=sqrt(sige)
tmp = diag(vcovar);
tstat = bhat ./ sqrt(tmp)
 
df=nobs-nexo
pvalue=ones(nexo,1)
for i=1:nexo
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
 
 
results('x') = [const, x , z]
results('nvar')  = nexo
results('yhat')  = yhat
results('beta')  = bhat
results('tstat') = tstat
results('pvalue') = pvalue
results('resid') = resid
results('vcovar') = vcovar
results('sigu') = sigu
results('sige') = sige
 
endfunction
