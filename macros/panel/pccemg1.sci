function rp=pccemg1(y,index,x)
 
// PURPOSE: Pesaran's common correlated effects
//  mean group estimator for heterogeneous panel models
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
// * x = (nobs*nindinv x k) matrix of exogeneous variables
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . rp('meth')='CCEMG'
//   . rp('y')     = y data vector
//   . rp('x')     = x data matrix
//   . rp('nobs')  = nobs
//   . rp('nvar')  = nvars
//   . rp('beta')  = bhat
//   . rp('betai') = individual regression coefficients
//   . rp('w')     = vector of individual weights
//   . rp('yhat')  = yhat
//   . rp('resid') = residuals
//   . rp('vcovar') = estimated variance-covariance matrix of
//      the CCCEP estimators
//   . rp('sige')  = estimated variance of the residuals
//   . rp('sigu')  = sum of squared residuals
//   . rp('ser')  = standard error of the regression
//   . rp('tstat') = t-stats (CCEP estimators and fixed effects)
//   . rp('pvalue') = pvalue of the betas
//   . rp('condindex') = multicolinearity cond index
//   . rp('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
// ------------------------------------------------------------
// REFERENCE:
//  Pesaran, M. H. (2006), "Estimation and inference in large
//    heterogenous panels with multifactor error structure",
//    Econometrica, 74, 967-1012.
// ------------------------------------------------------------
// Emmanuel Michaux (2013)
// http://grocer.toolbox.free.fr/grocer.html
 
[nobs,nx]=size(x);
uq=unique(index);
nindiv=size(uq,1);
nexo=nx+nindiv;
 
 
ni=sum(index(index==uq(1)))/uq(1);
for i=2:nindiv
  ni0=sum(index(index==uq(i)))/uq(i);
  if or(ni~=ni0) then
    error('CCEP estimator does''nt work with unbalanced panel');
  end
end
 
 
// build a (T x nx*nindiv) matrix of data
// // cross-sectional means
X=[];Y=[];
for i=1:nindiv
  id_i=find(index==uq(i));
  X=[X,x(id_i,1)];
  Y=[Y,y(id_i)];
end
csmx=mean(X,2);
csmy=mean(Y,2);
 
 
for j=2:nx
  X=[];
  for i=1:nindiv
    id_i=find(index==uq(i));
    X=[X,x(id_i,j)];
  end
  csmx=[csmx,mean(X,2)];
end
 
 
// projection matrix on the cross-sectional means
Z=[ones(ni,1),csmy,csmx];
Mz=eye(ni,ni)-Z*invxpx(Z)*Z';
 
 
xm0=zeros(nindiv,nx);ym0=zeros(nindiv,1);
const=zeros(nx*nindiv,nindiv);
bi=zeros(nx,nindiv);
for i=1:nindiv
  id_i=find(index==uq(i));
 
 
  yi=y(id_i);
  xi=x(id_i,:);
 
  bi(:,i)=inv(xi'*Mz*xi)*(xi'*Mz*yi);
 
  ym0(i)=mean(yi);
  xm0(i,:)=mean(xi,1);
 
 
  const(id_i,i)=1;
end
bmg=mean(bi,2);
 
 
// variance-covariance matrix
vcovar=(bi-bmg*ones(1,nindiv))*(bi-bmg*ones(1,nindiv))'/(nindiv-1);
 
 
// individual intercepts and their variance calculated by OLS
iintc=ym0-xm0*bmg;
bhat=[bmg ; iintc];
 
yhat=[x const]*bhat;
resid=y-yhat;
sigu=resid'*resid;
sige=sigu/(nobs-nexo);
ser=sqrt(sige);
vcovar2=sige/ni+xm0*vcovar*xm0';
 
 
tmp=[diag(vcovar/nindiv);diag(vcovar2)];
tstat=bhat./sqrt(tmp);
df=nobs-nexo;
pvalue=ones(nexo,1);
for i=1:nexo
  pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2;
end
 
condindex=bkwols([x const]);
llike=-0.5*nobs*(log(2*%pi)+log(sigu/nobs)+1);
 
rp=tlist(['results';'meth';'y';'x';'nobs';'nvar';'beta';'betai';'yhat';...
'resid';'vcovar';'sige';'sigu';'ser';'tstat';'pvalue';'condindex';...
'prescte';'llike'],...
'CCEMG',y,[x const],nobs,nexo,bhat,bi,yhat,resid,vcovar,sige,sigu,ser,tstat,...
pvalue,condindex,%t,llike);
 
 
endfunction
