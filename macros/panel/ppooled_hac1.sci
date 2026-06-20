function res=ppooled_hac1(y,index,x,typvcv,win)
 
// PURPOSE: performs Pooled HAC Least Squares for Panel Data
// (for balanced data)
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
// * typvcv = 1, 2 or 3 with
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
//   . res('meth')  = 'panel pooled'
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
//   . res('sige')  = estimated variance of the residuals
//   . res('ser')  = standard error of the regression
//   . res('tstat') = t-stats
//   . res('pvalue') = pvalue of the betas
//   . res('condindex') = multicolinearity cond index
//   . res('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . res('rsqr')  = rsquared
//   . res('rbar')  = rbar-squared
//   . res('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . res('pvaluef') = its significance level
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
// Copyright Emmanuel Michaux 2010-2012
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin < 4 then
  typvcv=1;
end
[nobs,nx]=size(x);
 
uniq=-gsort(-unique(index));
nindiv=size(uniq,1);
 
 
bhat=ols0(y,x);
yhat=x*bhat;
resid=y-yhat;
sigu=resid'*resid;
sige=sigu/(nobs-nx);
ser=sqrt(sige);
condindex=bkwols(x);
llike=-0.5*nobs*(log(2*%pi)+log(sigu/nobs)+1);
 
 
Ti=[];
list_indiv=list()
for i=1:nindiv
  id_i=find(index==uniq(i));
  Ti=[Ti;size(id_i,'*')];
  list_indiv($+1)=id_i
end
 
 
//"clustered" covariance matrix of Arellano (1987)
if typvcv==1 then
   xx=0;
   xuux=0;
   for i=1:nindiv
      id_i=list_indiv(i)
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
 
 
df=nobs-nx;
tmp=diag(vcovar);
tstat=bhat./sqrt(tmp);
pvalue=ones(nx,1);
for i=1:nx
  pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2;
end
 
 
if typvcv==1 then
  typvcv='clustered';
elseif typvcv==2 then
  typvcv='Driscoll-Kraay';
end
 
indcte=search_cte(x);
prescte=~isempty(indcte);
 
res=tlist(['results';'meth';'y';'x';'individual';'nobs';'nvar';'beta';'yhat';...
'resid';'vcovar';'sige';'sigu';'ser';'tstat';'pvalue';'condindex';...
'prescte';'llike';'hac';'win'],...
'panel pooled',y,x,index,nobs,nx,bhat,yhat,resid,vcovar,sige,sigu,ser,tstat,...
pvalue,condindex,prescte,llike,typvcv,win);
 
if prescte & nx ~=1 then
// there is a constant and at least another exogenous variable:
// R² and Rbar² make sense
  res=add_r2(res,sigu,y-mean(y),nobs,nx)
end
 
 
endfunction
