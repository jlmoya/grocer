function res=prandom1(meth,y,index,x,z)
 
// PURPOSE: performs Random Effects Estimation for Panel Data
//          (for balanced or unbalanced data)
// ------------------------------------------------------------
// INPUT:
// * meth = the gls estimation method used
//          ('wallace', 'swamy', 'amemiya' or 'nerlove')
// * y  = a (nobs x 1) vector of endogenous variable
// * index = a (nobs x 1) index vector that identifies each
//   observation with an individual
//   e.g. 1  (first 2 observations  for individual # 1)
//        1
//        2  (next  1 observation   for individual # 2)
//        3  (next  3 observations  for individual # 3)
//        3
//        3
// * x = matrix of exogenous variables
// * z = optional matrix of exogenous variables, dummy
//   variables.
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . res('meth')='panel with random effects'
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
//   . res('gls estimation method') = the gls method used
//   . res('random effects') = the estimation of the individual
//     effects
//   . res('res0') = residuals from the original model
//   . res('alfa') = the gls parameters
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
// adapted and extended from a matlab programm written by:
// Carlos Alberto Castro
// National Planning Department
// Bogota, Colombia
// Email: ccastro@dnp.gov.co
 
//****************************************************************************************
// NOTE: James P. LeSage provided corrections on the creation and use of the index
//       vector used to identify the the individual's observations.
// and Eric Dubois added his own ones
//****************************************************************************************
 
 
[nargout,nargin]=argn(0)
if nargin < 5 then
   z=[]
end
[nobs,nz] = size(z);
[nobs,nx] = size(x);
 
// creation of the id matrix using the vector index
uniq=unique(index)
 
nindiv = size(uniq,1);
nexo=nx+nindiv+nz
 
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
 
    id_i=find(index == uniq(i))
    list_types(i)=id_i
    ntypei=size(id_i,2)
    ntypes(i)=ntypei
    yi=y(id_i)
    meany=sum(yi)/ntypei
    ym(id_i) = meany
    ym0(i) = meany
    xi = x(id_i,:)
    meanxi=sum(xi,1)/ntypei
    xm(id_i,:) = ones(ntypei,1) .*. meanxi
    xm0(i,:)=meanxi
    if nz then
       zi = z(id_i,:)
       meanzi=sum(zi,1)/ntypei
       zm(id_i,:) = ones(ntypei,1) .*. meanzi
       zm0(i,:)=meanzi
    end
 
end
 
alfa=ones(nindiv,1)
 
if meth == 'wallace' then
// pooled estimation
   betap=ols0(y,[x z])
   residp=y-[x z]*betap
   sige1=0
   resid_dm=residp
   for i=1:nindiv
      id_i=list_types(i)
      resid1m=sum(residp(id_i))/ntypes(i)
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
 
   select meth
 
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
         residm= sum(residw(id_i))/ntypes(i)+iintc(i)-sum(iintc)/nindiv
         sige1=sige2+residm'*residm/(nindiv-nx-nz)
      end
   end
 
end
 
if meth ~= 'nerlove' then
   alfa=1-sqrt(sige2 ./ntypes/sige1)
   if min(alfa) < 0 then
      warning('method '+meth+' leads to a negative variance: switching to Nerlove''s method')
      iintc = ym0-xm0*betaw
      sige1=sum(ntypes)/nindiv*sum((iintc-sum(iintc)/nindiv).^2)/(nindiv-1)+sige2
      alfa=1-sqrt(sige2 ./ntypes/sige1)
   end
else
   iintc = ym0-xm0*betaw
   sige1=sum(ntypes)/nindiv*sum((iintc-sum(iintc)/nindiv).^2)/(nindiv-1)+sige2
   alfa=1-sqrt(sige2 ./ntypes/sige1)
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
 
xmatr=[const ztr xtr ]
 
// run OLS
 
res = ols2(ytr,xmatr);
resdo = y-[ones(nobs,1) z x ]*res('beta');
 
// individual intercepts
for i = 1:nindiv
   id_i=list_types(i)
   iintc(i)= (sige1-sige2/sum(ntypes)*nindiv)/(ntypes(i)*sige1)*sum(resdo(id_i));
end
 
res('meth')='panel with random effects'
 
// suppress dw which is meaningless
res(1)(16)=[]
res(16)=null()
res('llike')=llike
// add supplementary fields
res(1)($+1)='individual'
res(1)($+1)='gls estimation method'
res(1)($+1)='random effects'
res(1)($+1)='res0'
res(1)($+1)='alfa'
 
res('individual')=index
res('gls estimation method')=meth
res('random effects')=iintc
res('res0')=resdo
res('alfa')=alfa
 
endfunction
