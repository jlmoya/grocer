function rp=pdccemg1(y,index,yar,x,lg)
 
// PURPOSE: Pesaran and Chudik common correlated effects
//  mean group estimator for heterogenous dynamic panel data models
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
// * yar = a (nobs*nindiv x 1) vector of lagged (AR(1))
//    endogeneous variable
// * x = (nobs*nindinv x k) matrix of exogeneous variables
// * lg = lag of cross-sectional means for dynamic panel
//      estimation (default int(T^(1/3)))
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . rp('meth')='CCEMG'
//   . rp('y')     = y data vector
//   . rp('x')     = x data matrix
//   . rp('nobs')  = nobs
//   . rp('nvar')  = nvars
//   . rp('beta')  = bhat
//   . rp('betai')  = individual regression coefficients
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
//  Cubdik, A. & M.H. Pesaran (2013), "Commom correlated effects
//   estimation of heterogeneous dynamic panel data with
//   weakly exogenous regressors", Federal Reserve Bank of Dallas
//   Globalization and Monetary Policy Institute,
//   Working Paper No. 146
// ------------------------------------------------------------
// Emmanuel Michaux (2013)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0);
[nobs,nx]=size(x);
uq=unique(index);
nindiv=size(uq,1);
 
ni=sum(index(index==uq(1)))/uq(1);
for i=2:nindiv
  ni0=sum(index(index==uq(i)))/uq(i);
  if or(ni~=ni0) then
    error('CCEP estimator does''nt work with unbalanced panel');
  end
end
 
if (nargin<5) | (lg==[]) then
  lg=int(ni^(1/3));
end
 
ne=ni-lg;
nobs=ne*nindiv;
nar=1;
nexo=nx+nindiv+nar;
 
// build a (T x nx*nindiv) matrix of data
// // cross-sectional means
X=[];Y=[];Yar=[];
for i=1:nindiv
  id_i=find(index==uq(i));
  X=[X,x(id_i,1)];
  Y=[Y,y(id_i)];
  Yar=[Yar,yar(id_i)];
end
 
for j=2:nx
  for i=1:nindiv
    id_i=find(index==uq(i));
    X=[X,x(id_i,j)];
  end
end
 
// build a (T x nx*nindiv) matrix of data
// // cross-sectional means
idi=matrix(1:nx*nindiv,nindiv,nx)';
csmx=mean(X(:,idi(1,:)),2);
csmx=[csmx,mlag(csmx,lg,0)];// matrix of lags up to lg, with initial values set to 0
csmx=csmx(lg+1:$,:);
 
csmy=mean(Y(:,idi(1,:)),2);
csmy=[csmy,mlag(csmy,lg,0)];// matrix of lags up to lg, with initial values set to 0
csmy=csmy(lg+1:$,:);
 
for i=2:nx
  csmx_i=mean(X(:,idi(i,:)),2);
  csmx_i=[csmx_i,mlag(csmx_i,lg,0)];
  csmx=[csmx,csmx_i(lg+1:$,:)];
end
 
// projection matrix on the cross-sectional means
Z=[ones(ne,1),csmy,csmx];
Mz=eye(ne,ne)-Z*invxpx(Z)*Z';
 
Y=Y(lg+1:$,:);
Yar=Yar(lg+1:$,:);
X=X(lg+1:$,:);
 
xr=[];yr=[];
xm0=zeros(nindiv,nx+nar);ym0=zeros(nindiv,1);
const=zeros((nx+nar)*nindiv,nindiv);
bi=zeros(nx+nar,nindiv);
for i=1:nindiv
 
  Yi=Y(:,i);
  Xi=[Yar(:,i),X(:,idi(:,i))];
  bi(:,i)=inv(Xi'*Mz*Xi)*(Xi'*Mz*Yi);
 
  ym0(i)=mean(Yi);
  xm0(i,:)=mean(Xi,1);
 
  xr=[xr;Xi];
  yr=[yr;Yi];
end
bmg=mean(bi,2);
 
// variance-covariance matrix
vcovar=(bi-bmg*ones(1,nindiv))*(bi-bmg*ones(1,nindiv))'/(nindiv-1);
 
// individual intercepts and their variance calculated by OLS
iintc=ym0-xm0*bmg;
bhat=[bmg ; iintc];
 
const=eye(nindiv,nindiv).*.ones(ne,1);
yhat=[xr const]*bhat;
resid=yr-yhat;
sigu=resid(:)'*resid(:);
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
 
condindex=bkwols([xr const]);
llike=-0.5*nobs*(log(2*%pi)+log(sigu/nobs)+1);
 
 
rp=tlist(['results';'meth';'y';'x';'nobs';'nvar';'beta';'betai';'yhat';...
'resid';'vcovar';'sige';'sigu';'ser';'tstat';'pvalue';'condindex';...
'prescte';'llike'],...
'dynamic CCEMG',yr,xr,nobs,nexo,bhat,bi,yhat,resid,vcovar,sige,sigu,ser,tstat,...
pvalue,condindex,%t,llike);
 
 
endfunction
