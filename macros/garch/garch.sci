function [rgarch]=garch(grocer_namey,varargin)
 
// PURPOSE: regression estimation with garch(p,q) errors
//          y(t) = X(t)*b + e(t), e(t) = N(0,h(t))
//          h(t) = a0 +
//                 ar(1)*h(t-1) + ... + ar(p)*h(t-p) +
//                 ma(1)*e(t-1)^2  + ... + ma(q)*e(t-q)^2
// ------------------------------------------------------------
// REFERNCES: Green (2000) Econometric Analysis
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * varargin = arguments which can be:
//   - a time series
//   - a real (nxp) vector
//   - a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   - the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   - the string 'dropna' if the user wants to delete NAs
//   - 'b = xx' where xx is a (k x 1) vector of B starting
//      values
//   - 'a0 = xx' where xx is a0 starting values to feed the
//     maximisation programm
//   - 'ar = xx' where xx is (p x 1) vector of ar starting
//     values to feed the maximisation programm
//   - 'ma = xx' where xx is (q x 1) vector of ma starting
//     values to feed the maximisation programm
//   - 'optfunc=optim' if the user wants to use the optim
//   optimisation function (default: optimg)
//   - 'opt_nelmead=crit,nitermax' with crit the value of the
//   convergence criterion in the Nelder-Meade optimisation
//   function and nitermax the maximum number of iterations
//   (default = 'opt_nelmead=2*%eps,1000')
//   - 'opt_optim=opts' where opts are options for optim
//   that can be entered after the starting value of the
//   parameters
//   (default = 'opt_optim=,''ar'',1e6,1e6'')
//   - 'opt_convg=val' where val is the threshold on gradient
//   norm
//   (default = 'opt_convg=1e-5')
// ------------------------------------------------------------
// OUTPUT:
// a result tlist with:
//   . rgarch('meth')  = 'garch'
//   . rgarch('optmeth')  = 'optim' or 'maxlik' (method used
//                         (the optimisation)
//   . rgarch('y')     = y data vector
//   . rgarch('x')     = x data matrix
//   . rgarch('nobs')  = # observations
//   . rgarch('nvar')  = # variables
//   . rgarch('beta')  = bhat
//   . rgarch('yhat')  = yhat
//   . rgarch('resid') = residuals
//   . rgarch('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rgarch('sige')  = estimated variance of the residuals
//   . rgarch('sigu')  = sum of squared residuals
//   . rgarch('ser')  = standard error of the regression
//   . rgarch('tstat') = t-stats
//   . rgarch('pvalue') = pvalue of the betas
//   . rgarch('dw')    = Durbin-Watson Statistic
//   . rgarch('condindex') = multicolinearity cond index
//   . rgarch('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rgarch('b')  = estimated b
//   . rgarch('a0')  = estimated a0
//   . rgarch('ar')  = estimated ar
//   . rgarch('ma')  = estimated ma
//   . rgarch('sigt')  = estimated h(t)
//   . rgarch('like')  = log-likelihood
//   . rgarch('parm1')  = vector of stacked parameters
//   . rgarch('aic')  = Aka�ke information criterion
//   . rgarch('bic')  = Schwarz information criterion
//   . rgarch('hq')  = Hannan-Quinn information criterion
//   . rgarch('rbar')  = rbar-squared
//   . rgarch('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rgarch('pvaluef') = its significance level
//   . rgarch('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rgarch('namey') = name of the y variable
//   . rgarch('namex') = name of the x variables
//   . rgarch('dropna') = boolean indicating if NAs have
//		   been dropped
//   . rgarch('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rgarch('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// Copyright Eric Dubois 2002-2013
// http://grocer.toolbox.free.fr/grocer.html
// adapted (a lot) to scilab from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
// thanks to Catherine Bac to have pointed a bug to me
 
grocer_prt=%t
grocer_dropna=%f
grocer_optfunc='optimg'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],'',',2*%eps,1000',1e-5)
 
grocer_nargin=length(varargin)
 
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi2=strsubst(varargin(grocer_i),' ','')
      grocer_indeq=strindex(grocer_argi2,'=')
      if size(grocer_indeq,2)>1 then
         error('argument should have only one ''='' sign')
 
      elseif size(grocer_indeq,2) == 1 then
         grocer_argi2a=strsubst(part(grocer_argi2,1:grocer_indeq-1),' ','')
         grocer_argi2b=part(grocer_argi2,grocer_indeq+1:length(grocer_argi2))
         if or(grocer_argi2a == ['b' ; 'a0' ; 'ar' ; 'ma']) then
            execstr('grocer_'+varargin(grocer_i))
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'optfunc' then
             grocer_optfunc=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_nelmead' then
             grocer_opt_optim('nelmead')=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_optim' then
            grocer_opt_optim('optim')=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_optim_ineq' then
            grocer_opt_optim('optim ineq')=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_convg' then
            grocer_opt_optim('convg')=evstr(grocer_argi2b)
            varargin(grocer_i)=null()
         end
 
      elseif grocer_argi2 == 'noprint' then
         grocer_prt=%f
 
      elseif grocer_argi2 == 'dropna' then
         grocer_dropna=%t
 
      end
   end
end
 
if isempty(varargin)  then
//   [grocer_y,grocer_namey,grocer_prests,grocer_boundsvarb,nonna]=...
//   explouniv(grocer_namey,[],[],'endogenous',%t,grocer_dropna)
 
  [grocer_y,grocer_namey,grocer_prests,grocer_boundsvarb,grocer_nonna]=...
      explone(grocer_namey,[],'endogenous',%t,grocer_dropna)
   grocer_namey=grocer_namey(1)
   grocer_x=[]
   grocer_b=[]
 
else
   [grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nonna]=...
   explouniv(grocer_namey,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
end
 
 
[nar,j1]=size(grocer_ar)
[nma,j2]=size(grocer_ma)
if j1 ~= 1 then
   if nar ~= 1 then
      error('ar sould be a (nx1) or a 1xn) vector')
   else
      nar=j1
      grocer_ar=grocer_ar'
   end
end
if j2 ~= 1 then
   if nma ~= 1 & ~isempty(grocer_ma) then
      error('ma sould be a (nx1) or a 1xn) vector')
   else
      nma=j2
      grocer_ma=grocer_ma'
   end
end
 
parm=[grocer_b ; grocer_a0 ; grocer_ar ; grocer_ma]
nobs=size(grocer_y,1)
k=size(grocer_x,2)
grocer_nparam=k+1+nar+nma
 
deff('[f,g,ind]=cost(p,ind,nar,nma,grocer_y,grocer_x)',...
     ['f=garch_like(p,nar,nma,grocer_y,grocer_x)',...
     'g=garch_grad2(p,nar,nma,grocer_y,grocer_x)']);
// Do maximum likelihood estimation
select grocer_optfunc
case 'optim' then
   execstr('[like,parm1] = optim(list(cost,nar,nma,grocer_y,grocer_x)'...
   +grocer_opt_optim('optim ineq')+',parm'+grocer_opt_optim('optim')+')')
 
case 'optimg' then
   [like,parm1] = optimg(list(garch_like,nar,nma,grocer_y,grocer_x),...
                  list(cost,nar,nma,grocer_y,grocer_x),parm,...
                  grocer_opt_optim('optim'),grocer_opt_optim('nelmead'),grocer_opt_optim('convg'));
else
   error('not an available optimisation function'+grocer_optfunc)
end
like=-like
 
// transform parm
parmd = garch_trans(parm1,k);
 
bhat = parmd(1:k)
a0=parmd(k+1)
ar=parmd(k+2:k+1+nar)
ma=parmd(k+2+nar:grocer_nparam)
 
if k == 0 then
   yhat=0*grocer_y
else
   yhat = grocer_x*bhat;
end
 
resid = grocer_y-yhat;
sigu = resid'*resid;
sige=sigu/(nobs-k)
ser=sqrt(sige)
 
// calculate gradient at the solution
[g,dht,scores,sigt]=garch_grad(parmd,nar,nma,grocer_y,grocer_x)
 
// calculate information matrix at the solution
 
inform=zeros(k+1+nar+nma,k+1+nar+nma)
for i=1:nobs
   inform(1:k,1:k)=inform(1:k,1:k)+grocer_x(i,:)'*grocer_x(i,:)/sigt(i)+...
   0.5*dht(i,1:k)'*dht(i,1:k)/sigt(i)^2
   inform(k+1:k+1+nar+nma,k+1:k+1+nar+nma)=...
   inform(k+1:k+1+nar+nma,k+1:k+1+nar+nma)+...
   0.5*dht(i,k+1:k+1+nar+nma)'*dht(i,k+1:k+1+nar+nma)/sigt(i)^2
end
 
// calculate outer products matrix at the solution
op=zeros(k+1+nar+nma,k+1+nar+nma)
for i=1:nobs
   op=op+scores(i,:)'*scores(i,:)
end
 
// calculate var_cov matrix of parameters
vcovar=inv(inform)*op*inv(inform)
 
stdhat = sqrt(diag(vcovar));
 
tstat = parmd ./ stdhat;
 
ym = grocer_y-mean0(grocer_y);
ediff = resid(2:nobs)-resid(1:nobs-1)
dw = ediff'*ediff/sigu
// durbin-watson
 
df=nobs-k
pvalue=ones(grocer_nparam,1)
for i=1:grocer_nparam
   pvalue(i)=(1-cdfnor("PQ",abs(tstat(i)),0,1))*2
end
 
condindex=bkwols(grocer_x)
 
prescte=%f
if k ~= 1 then
   i=1
   while (i <= k) & ~prescte then
      // if all values are equal to the first one then,
      // the variable is constant
      prescte=and(grocer_x(:,i) == grocer_x(1,i))
      i=i+1
   end
end
aic=-2*like/nobs+2*grocer_nparam/nobs-1-log(2*%pi)
bic=-2*like/nobs+grocer_nparam*log(nobs)/nobs-1-log(2*%pi)
 
hq=-2*like/nobs+2*grocer_nparam*log(log(nobs))/nobs-1-log(2*%pi)
 
rgarch = tlist(['results';'meth';'y';'x';'nobs';'nvar';...
'beta';'yhat';'resid';'vcovar';'sige';'sigu';'ser';'tstat';'stdhat';...
'pvalue';'dw';'condindex';'prescte';'b';'a0';'ar';'ma';'sigt';...
'like';'grad';'parm1';'aic';'bic';'hq']...
,'garch',grocer_y,grocer_x,nobs,grocer_nparam,parmd,yhat,...
resid,vcovar,sige,sigu,ser,tstat,stdhat,...
pvalue,dw,condindex,prescte,bhat,a0,ar,ma,sigt,like,g,parm1,aic,bic,hq)
 
if prescte then
// there is a constant and at least another exogenous variable:
// R� and Rbar� make sense
  rsqr1 = sigu;
  rsqr2 = ym'*ym;
  // r-squared
  rgarch(1)($+1)='rsqr'
  rsqr=1-rsqr1/rsqr2
  rgarch('rsqr') =rsqr
  nobsm1=nobs-1
  nvarm1=k-1
  rgarch(1)($+1)='rbar'
  rgarch('rbar') = 1-rsqr1/df/rsqr2*nobsm1
  // rbar-squared
  f=rsqr/(1-rsqr)*df/(k-1)
  pvaluef=1-cdff("PQ",f,nvarm1,nobs-k)
  rgarch(1)($+1)='f'
  rgarch('f') = f
  rgarch(1)($+1)='pvaluef'
  rgarch('pvaluef') = pvaluef
end
 
 
// saves the names, the bounds if the regression involves ts
rgarch(1)($+1) = 'prests'
rgarch(1)($+1) = 'namex'
rgarch(1)($+1) = 'namey'
rgarch(1)($+1) = 'dropna'
rgarch('prests')=grocer_prests
rgarch('dropna')=grocer_dropna
 
if grocer_x~=[] then
  namex=[grocer_namexos ; 'sig0']
else
  namex='sig0'
end
 
for i=1:nar
   namex=[namex ; 'sig_ar('+string(i)+')']
end
for i=1:nma
   namex=[namex ; 'sig_ma('+string(i)+')']
end
rgarch('namex')=namex
rgarch('namey')=grocer_namey
if grocer_prests then
   rgarch(1)($+1) = 'bounds'
   rgarch('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rgarch(1)($+1)='nonna'
   rgarch('nonna')=nonna
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
   prt_garch(rgarch,%io(2))
   plt_garch(rgarch)
end
endfunction
