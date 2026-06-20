function rpanel=pfixed_hac1(y,index,x,typvcv,win)
 
// PURPOSE: performs Fixed Effects Estimation for Panel Data
// (for balanced or unbalanced data) using the within-groups
//  estimation procedure and Asymptotic Robust VCV .
// ------------------------------------------------------------
// INPUT:
// * y = a (nobs*nindiv x 1) matrix of all of the individual's
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
// * x = a (nobs*nindiv x k) matrix of exogenous variables
// * typvcv = 1 or 2 with
//    - 1 "clustered" covariance matrix of Arellano (1987)
//      recommended when T is fixed and N large
//      but also "works" when T is large and N fixed
//      see Hansen C. B. (2007) (reference below)
//    - 2 a Newey-west type (Driscoll-Kraay) estimator
//      recommended when T is large and N fixed
// * win = the length of the Barlett window kernel estimator
//      (default = automatic selection by Andrews (1991)
//        using an AR(1) model)
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
//   . res('hac') = type of robust variance matrix in case of HAC
//        estimation
// ------------------------------------------------------------
// REFERENCE:
// * Andrews Donald W. K. (1991), "Heteroskedasticity and Autocorrelation
//     Consistent Covariance Matrix Estimation", Econometrica, 59, 817-858
// * Arellano M. (2003), "Panel Data Econometrics", ed. OUP
// * Driscoll J.C. & A. C. Kraay (1998),"Consistent Covariance
//    Matrix Estimation With Spatially Dependent Panel Data",
//    Review of Ecomomics & Statistics, 80, 549-560.
// * Green W. H. (2000), "Econometric Analysis", 4th ed, Prentice Hall
// * Hansen C. B. (2007), "Asymptotic Properties of a Robust Variance
//    Matrix for Panel Data when T is Large", Journal of Econometrics,
//    141, 597-620.
// ------------------------------------------------------------
// Copyright Eric Dubois 2005 & Emmanuel Michaux 2010-2012
// http://grocer.toolbox.free.fr/grocer.html
 
 
 
 
[nargout,nargin]=argn(0)
if nargin < 4 then
  typvcv=1;
end
z=[];
[nobs,nz]=size(z);
[nobs,nx]=size(x);
//
uniq=-gsort(-unique(index));
nindiv=size(uniq,1);
nexo=nx+nindiv+nz;
const=zeros(nobs,nindiv);
 
 
 
// transformation of all the variables used
// the variables are expressed as deviations from the individual means
// so calculate first the individual means
xm=0*x;
zm=0*z;
ym=0*y;
xm0=zeros(nindiv,nx);
zm0=zeros(nindiv,nz);
ym0=zeros(nindiv,1);
ntypes=ones(nindiv,1);
 
Ti=[]
for i = 1:nindiv
    id_i=find(index == uniq(i));
    ntypei=size(id_i,2);
    Ti=[Ti;ntypei];
    ntypes(i)=ntypei;
    yi=y(id_i);
    meany=mean(yi);
    ym(id_i) = meany;
    ym0(i) = meany;
    xi = x(id_i,:);
    meanxi=mean(xi,1);
    xm(id_i,:) = ones(size(id_i,2),1) .*. meanxi;
    xm0(i,:)=meanxi;
    if nz then
       zi = z(id_i,:)
       meanzi=mean(zi,1)
       zm(id_i,:) = meanzi;
       zm0(i,:)=meanzi;
    end
    const(id_i,i)=1;
end
xnew=[x-xm z-zm];
[xpxi,xpxixp]=invxpx(xnew)
bhat=xpxixp*y
 
// individual intercepts and their variance calculated
// by the mean of the Frish-Vaugh theorem
iintc = ym0-[xm0 zm0]*bhat;
 
yhat = [x z const]*[bhat ; iintc];
resid=y-yhat;
sigu=resid'*resid;
sige=sigu/(nobs-nexo);
ser=sqrt(sige);
condindex=bkwols([x z const]);
llike=-0.5*nobs*(log(2*%pi)+log(sigu/nobs)+1);
 
 
// R² and Rbar² make sense
rsqr1 = sigu;
ymm=y-mean(y);
rsqr2 = ymm'*ymm;
// r-squared
 
 
rsqr=1-rsqr1/rsqr2;
nobsm1=nobs-1;
nvarm1=nexo-1;
 
 
//"clustered" covariance matrix of Arellano (1987)
vcovar=zeros(nexo,nexo)
adjt=ones(nexo,1);
df=(nobs-nexo)*ones(nexo,1);
if typvcv==1 then
  eps=y-ym-xnew*bhat;
  xx=0;
  xuux=0;
  for i=1:nindiv
    id_i=find(index==uniq(i));
    eps_i=eps(id_i);
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
 
  // balanced panel case
  if length(unique(Ti))==1;
//    W=[x,z,const];
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
      win=1.1447*(al*Ti(1))^(1/3);
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
 
 
  else
    error('Newey-West type variance matrix doesn''t work with unbalanced panel');
  end
end
// Variances of the fixed effects remain unchanged see Green (2000) p. 579
vcovar(1:nindiv,1:nindiv)=sige*([xm0 zm0]*xpxi*[xm0 zm0]'+diag(1 ./ ntypes))
vcovar(nindiv+1:nexo,1:nindiv)=-sige*xpxi*[xm0 zm0]'
vocvar(1:nindiv,nindiv+1:nexo)=vcovar(nindiv+1:nexo,1:nindiv)'
 
 
 
 
bhat=[iintc ; bhat];
tmp = diag(vcovar);
tstat = bhat./sqrt(tmp)
pvalue=ones(nexo,1)
 
 
// in case of CCM VCV matrix t-stat are adjusted according to Hansen (2005)
for i=1:nexo
  pvalue(i)=(1-cdft("PQ",abs(adjt(i)*tstat(i)),df(i)))*2
end
 
 
rbar = 1-rsqr1/df($)/rsqr2*nobsm1;
// rbar-squared
if rsqr ~= 1 then
  f=rsqr/(1-rsqr)*df($)/(nexo-1)
else
  warning('rsqr = 1: your exogenous variables are exactly colinear')
  f=%inf
end
pvaluef=1-cdff("PQ",f,nvarm1,nobs-nexo)
 
 
if typvcv==1 then
  typvcv='clustered';
elseif typvcv==2 then
  typvcv='Driscoll-Kraay';
end
 
 
rpanel = tlist(['results';'meth';'y';'x';'nobs';'nvar';'beta';'yhat';...
'resid';'vcovar';'sige';'sigu';'ser';'tstat';'pvalue';'condindex';...
'prescte';'llike';'rsqr';'rbar';'f';'pvaluef';'hac';'win';'individual']...
,'panel with fixed effects',y,[x z const],nobs,nexo,bhat,yhat,resid,vcovar,sige,sigu,ser,tstat,...
pvalue,condindex,%t,llike,rsqr,rbar,f,pvaluef,typvcv,win,index)
 
 
endfunction
