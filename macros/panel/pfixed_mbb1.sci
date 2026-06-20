function res=pfixed_mbb1(y,index,x,B,alpha)
 
// PURPOSE: Fixed effects estimation for panel data
//  using the within-groups estimation procedure
//  and moving-block bootstrap percentile-t confidence intervals
//  for the coefficients
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
// * mol = moving blocks length
// * B = number of bootstrap replications
// * alpha = confidence level
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . res('meth')='panel with fixed effects'
//   . res('y')     = y data vector
//   . res('x')     = x data matrix
//   . res('nobs')  = nobs
//   . res('nvar')  = nvars
//   . res('beta')  = bhat
//   . res('yhat')  = yhat
//   . res('resid') = residuals
//   . res('vcovar') = estimated variance-covariance matrix of
//     beta
//   . res('sige')  = estimated variance of the residuals
//   . res('sigu')  = sum of squared residuals
//   . res('ser')  = standard error of the regression
//   . res('tstat') = t-stats
//   . res('pvalue') = pvalue of the betas
//   . res('condindex') = multicolinearity cond index
//   . res('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . res('lliked') = log-likelihood
//   . res('rsqr')  = rsquared
//   . res('rbar')  = rbar-squared
//   . res('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . res('pvaluef') = its significance level
//   . res('hac') = type of robust variance matrix in case of HAC
//        estimation
// ------------------------------------------------------------
// REFERENCE:
// * Andrews Donald W. K. (1991), "Heteroskedasticity and Autocorrelation
//     Consistent Covariance Matrix Estimation", Econometrica, 59, 817-858
// * Gonçalves S. (2011), 'The moving blocks bootstrap for panel
//     linear regression models with individual fixed effects",
//     Econometric Theory, 27, 1048-1082.
// * Green W. H. (2000), "Econometric Analysis", 4th ed, Prentice Hall
// ------------------------------------------------------------
//  Emmanuel Michaux 2012
// http://grocer.toolbox.free.fr/grocer.html
 
 
if int(alpha*(B+1))~=alpha*(B+1) then
  warning('it is desirable for alpha*(nboot+1) to be chosen such as to be an integer')
end
 
 
[nobs,nx]=size(x);
uq=unique(index);
nindiv=size(uq,1);
T=nobs/nindiv;
nexo=nx+nindiv;
 
 
ni=sum(index(index==uq(1)))/uq(1);
for i=2:nindiv
  ni0=sum(index(index==uq(i)))/uq(i);
  if or(ni~=ni0) then
    error('Moving block bootstrap can only be performed on balanced panel database');
  end
  ni=[ni,ni0];
end
 
 
// build a (T x nx*nindiv) matrix of data
// to order the data by individuals
X=[];Y=[];
idx=1:nindiv:(nx*nindiv);
idx2=vec(matrix(1:(nx*nindiv),nindiv,nx)')';
for j=1:nx
  for i=1:nindiv
    id_i=find(index==uq(i));
    X=[X,x(id_i,j)];
    if j==1 then
      Y=[Y,y(id_i)];
    end
  end
end
xo=matrix(X(:),nobs,nx);yo=Y(:);
 
rp0=pfixed0(yo,index,xo,[]);
xdm=xo-rp0('xmean');eps=rp0('resid');bet=rp0('beta');
bhat=[bet;rp0('fixed')];const=rp0('const');
 
sn=xdm.*(eps*ones(1,nx));
sn=matrix(sn,T,nx*nindiv);
sn=matrix(vec(sn(:,idx2)),nx*T,nindiv);
sn=matrix(sum(sn,2),T,nx);
 
// Andrews (1991) method based on approximating AR(1) model
// for \hat{s}_{n,t}/n to determine block length
write(%io(2),'      Andrews automatic lag truncation selection','(a)');
num=zeros(nx,1);den=num;
for j=1:nx
  tmpo=ols1(sn(2:$,j),[sn(1:$-1,j),ones(T-1,1)]);
  phi=tmpo('beta')(1);
  sigma=sqrt(tmpo('sige'));
  num(j)=4*phi^2*sigma^4/((1-phi)^6*(1+phi)^2);
  den(j)=sigma^4/(1-phi)^4;
end
al=sum(num)/sum(den);
kl=1.1447*(al*T)^(1/3);
write(%io(2),' estimated lag truncation: '+string(kl),'(a)');
 
Bnt=sn'*sn;
i=1;
while abs(i/kl)<=1 then
  Bnt_i=sn(1:($-i),:)'*sn((i+1):$,:);
  Bnt=Bnt+(1-abs(i/kl))*(Bnt_i+Bnt_i');
  i=i+1;
end
Bnt=Bnt/(T*nindiv^2);
Ant=xdm'*xdm/nobs;
Cnt=inv(Ant)*Bnt*inv(Ant);
sigCnt=sqrt(diag(Cnt));
 
 
// adjust the length of the blocks
// such that the number blocks
//  is an integer
if kl<1 then
  mol=1;
elseif kl>0.9*T
  mol=0.3*T;
else
  mol=int(kl);
end
 
// Bootstrap replications
[ovb,selb,kb,re]=movblockboot(T,mol,B);
ids=0:mol:T;
if ids($)~=T then
  ids=[ids,T];
end
mbet=zeros(B,nx);
mCnt=zeros(B,nx*(nx+1)/2);
mstu=zeros(B,nx);
 
write(%io(2),'    Bootstrap step, be patient...','(a)');
for b=1:B
  selb_b=vec(ovb(:,selb(:,b)));
  selb_b=selb_b(1:$-re); // truncate the last block when necessary
 
  X_b=X(selb_b,:);
  Y_b=Y(selb_b,:);
 
  x_b=matrix(X_b,nobs,nx);
  y_b=Y_b(:);
 
  rp_b=pfixed0(y_b,index,x_b,[]);
  xdm_b=x_b-rp_b('xmean');eps_b=rp_b('resid');bet_b=rp_b('beta');
 
  sn_b=xdm_b.*(eps_b*ones(1,nx));
  sn_b=matrix(sn_b,T,nx*nindiv);
  sn_b=matrix(vec(sn_b(:,idx2)),nx*T,nindiv);
  sn_b=matrix(sum(sn_b,2),T,nx);
 
  Bnt_b=0;
  for j=1:kb
    Ssn_b_j=sum(sn_b((ids(j)+1):ids(j+1),:),1);   // see eq (4) in Gonçalves (2011)
    Bnt_b=Bnt_b+Ssn_b_j'*Ssn_b_j;
  end
  Bnt_b=Bnt_b/(T*nindiv^2);
  Ant_b=xdm_b'*xdm_b/nobs;
  Cnt_b=inv(Ant_b)*Bnt_b*inv(Ant_b);
 
  mbet(b,:)=bet_b';
  mCnt(b,:)=vech(Cnt_b)';
  mstu(b,:)=sqrt(T)*(bet_b'-bet')./sqrt(diag(Cnt_b)');
end
 
 
// symetric-t bootstrap confidence interval
qu=alpha*(B+1);             // here alpha is defined as 1-alpha, i.e. 95% rather than 5%
cibet_s=zeros(nx,2);
//qu_l=(1-(1-alpha)/2)*(B+1);
//qu_u=(1-alpha)*(B+1)/2;
//cibet_as=zeros(nx,2);
amstu=abs(mstu);
for i=1:nx
  oamstu=-gsort(-amstu(:,i));
  cibet_s(i,:)=[bet(i)-sigCnt(i)*oamstu(qu)/sqrt(T),bet(i)+sigCnt(i)*oamstu(qu)/sqrt(T)];
 
//  omstu=-gsort(-mstu(:,i));
//  cibet_as(i,:)=[bet(i)-sigCnt(i)*omstu(qu_l),bet(i)-sigCnt(i)*omstu(qu_u)];
end
 
 
sigu=eps'*eps;
sige=sigu/(nobs-nexo);
ser=sqrt(sige);
condindex=bkwols([x const]);
llike=-0.5*nobs*(log(2*%pi)+log(sigu/nobs)+1);
 
 
// R^2 and Rbar^2 make sense
rsqr1=sigu;
ymm=y-mean(y);
rsqr2=ymm'*ymm;
// r-squared
rsqr=1-rsqr1/rsqr2;
nobsm1=nobs-1;
nvarm1=nexo-1;
rbar = 1-rsqr1/(nobs-nexo)/rsqr2*nobsm1;
 
 
res=tlist(['results';'meth';'y';'x';'nobs';'nvar';'beta';'yhat';...
'resid';'vcovar';'sige';'sigu';'ser';'ci';'lblock';'condindex';...
'prescte';'llike';'rsqr';'rbar';'hac']...
,'panel with fixed effects',y,[x const],nobs,nexo,bhat,rp0('yhat'),eps,Cnt,sige,sigu,ser,...
cibet_s,mol,condindex,%t,llike,rsqr,rbar,'moving blocks bootstrap')
 
 
endfunction
