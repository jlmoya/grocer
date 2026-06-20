function rvar=autovar2var(rauto,type_mod,rank_mod)
 
// PURPOSE: transform a tlist result from the automatic VAR
// estimation into a proper VAR tlist, for axample for the
// sake of IRF calculations. Rsqr, Rbar and derived statistics
// are absent even in the presence of constants in the eqaution
// because they are meaningless in this case.
// ------------------------------------------------------------
// INPUT:
// * rauto = a results tlist from automatic applied to a VAR
//   model (therefore typeof(rauto) is 'results' and
//   rauto('meth') is 'automatic' and rauto('estim') is 'var'
// * rauto = the type of results that must be transformed
//   ('final', 'stage 1 models', etc.)
// * rank_mod = the rank of the model in the list of results
//   when the result is made of potentially several models
//   ('stage 1 models', 'stage 2 models', etc.)
// ------------------------------------------------------------
// OUTPUT:
// rvar = a tlist with
//   . rvar('meth')  = 'restricted var'
//   . rvar('y')     = y data vector
//   . rvar('x')     = x data matrix
//   . rvar('nobs')  = # observations
//   . rvar('nvar')  = # exogenous variables
//   . rvar('neqs')  = # endogenous variables
//   . rvar('resid') = residuals, with rvar('resid')(:,i):
//                     residuals for equation # i
//   . rvar('beta')  = bhat, with rvar('beta')(:,i):
//                     coefficients for equation # i
//   . rvar('rsqr')  = rsquared, with rvar('rsqr')(i) :
//                     rsquared for equation # i
//   . rvar('overallf') = F-stat for the nullity of
//                     coefficients other than the constant
//                     with: rvar('f')(i): F-stat for equation
//                     # i
//   . rvar('pvaluef') = their significance level with:
//                     rvar('pvaluef')(i): significance level
//                     for equation # i
//   . rvar('rbar')  = rbar-squared
//   . rvar('sigu')  = sums of squared residuals with
//                     rvar('sigu')(:,i): sum of squared
//                     residuals for equation # i
//   . rvar('ser')   = standard errors of the regression with
//                    rvar('ser')(i): standard error for
//                    equation # i
//   . rvar('tstat') = t-stats, with rvar('tstat')(:,i):
//                     t-stat for equation # i
//   . rvar('pvalue')= pvalue of the betas, with
//                      rvar('pvalue')(:,i): p-value for
//                      equation # i
//   . rvar('dw')    = Durbin-Watson Statistic, with:
//                    rvar('dw')(i): DW for equation # i
//   . rvar('condindex') = multicolinearity cond index, with
//                         rvar('condindex')(i): cond index for
//                         equation # i
//   . rvar('boxq') = Box Q-stat, with rvar('boxq')(i):
//                    Box Q-stat for equation # i
//   . rvar('sigma') = (neqs x neqs) var-covar matrix of the
//                     regression
//   . rvar('aic') = Akaïke information criterion
//   . rvar('bic') = Schwartz information criterion
//   . rvar('hq') = Hannan-Quinn information criterion
//   . rvar('xpxi') = inv(X'X)
//   . rvar('vcovar') = variance amtrix of the vector of all
//     coefficents
//   . rvar('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rvar('nx') = # of x variables
//   . rvar('namey') = name of the y variable
//   . rvar('namex') = name of the x variables (if any)
//   . rvar('dropna') = boolean indicating if NAs had
//     been dropped
//   . rvar('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rvar('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013
// http://grocer.toolbox.free.fr/grocer.html
 
 
nargin=argn(2)
ri=rauto('initial model')
nobs=ri('nobs')
nlag=ri('nlag')
neqs=ri('neqs')
nexoall=size(ri('beta'),'*')
nx=(size(ri('beta'),'*')-nlag*neqs^2)/neqs
 
select nargin
case 2
   rf=rauto(type_mod)
case 3
   rglob=rauto(type_mod)
   rf=rglob(rank_mod*3)
end
 
nvar=rf('nvar')
indx=rf('indx')
ncomp=rf('ncomp')
 
prescte=zeros(neqs,1)
bet=zeros(ri('nvar')(1)-ncomp,neqs)
tstat=bet
pvalue=bet
boxq=zeros(1,neqs)
condindex=zeros(1,neqs)
vcovar=zeros(nexoall,nexoall)
 
bet(indx)=rf('beta')(ncomp*neqs+1:$)
bet=[bet ; matrix(rf('beta')(1:ncomp*neqs),-1,neqs)]
tstat(indx)=rf('tstat')(ncomp*neqs+1:$)
tstat=[tstat ; matrix(rf('tstat')(1:ncomp*neqs),-1,neqs)]
pvalue(indx)=rf('pvalue')(ncomp*neqs+1:$)
pvalue=[pvalue ; matrix(rf('pvalue')(1:ncomp*neqs),-1,neqs)]
vcovar(indx,indx)=rf('vcovar')(ncomp*neqs+1:$,ncomp*neqs+1:$)
vcovar(indx,nexoall-ncomp*neqs+1:nexoall)=rf('vcovar')(ncomp*neqs+1:$,1:ncomp*neqs)
vcovar(nexoall-ncomp*neqs+1:nexoall,indx)=rf('vcovar')(1:ncomp*neqs,ncomp*neqs+1:$)
vcovar(nexoall-ncomp*neqs+1:nexoall,nexoall-ncomp*neqs+1:nexoall)=rf('vcovar')(1:ncomp*neqs,1:ncomp*neqs)
 
cumnvar=[0 ; cumsum(nvar)]
for i=1:neqs
   x=rf('x')(1+(i-1)*nobs:i*nobs,cumnvar(i)+1:cumnvar(i+1))
   nobse=nobs-nvar(i)
   condindex(i)=bkwols(x)
   resid=rf('resid')(:,i)
   elag = mlag(resid,nobse/6);
   // feed the lags
   etrunc = elag(nobse/6+1:nobse,1);
   rtrunc = resid(nobse/6+1:nobse);
 
   qres = ols1(rtrunc,etrunc);
   boxq(:,i)=(rtrunc'*rtrunc/qres('sigu')-1)*5/6*nobse/(nobse/6-1);
end
 
namex=strsubst(ri('namex')([1:nexoall/neqs ]),'eq 1.','')
for i=1:size(namex,1)
   ind_leftpar=strindex(namex(i),'(-')
   if ~isempty(ind_leftpar) then
      lagi=part(namex(i),ind_leftpar($)+2:length(namex(i))-1)
      namex(i)='lagts('+lagi+','+part(namex(i),1:ind_leftpar($)-1)+')'
   end
end
 
rvar=tlist(['results';'meth';'yall';'y';'x';'nvar';'nobs';...
'neqs';'nlag';'resid';'beta';'tstat';'pvalue';'sigu';'ser';'dw';'condindex';...
'boxq';'sigma';'aic';'bic';'hq';'vcovar';...
'prescte';'nx';'namey';'namex';'prests';'dropna'],...
'restricted var',ri('yall'),ri('y'),ri('x'),ri('nvar')(1),ri('nobs'),...
neqs,ri('nlag'),rf('resid'),bet,tstat,pvalue,...
rf('sigu'),rf('ser'),rf('dw'),condindex,...
boxq,rf('sigma'),rf('aic'),rf('bic'),rf('hq'),vcovar,...
%f,nx,rf('namey'),namex,rf('prests'),rf('dropna'))
 
if rf('prests') then
   rvar(1)($+1)='bounds'
   rvar($+1)=rf('bounds')
end
 
if rf('dropna') then
   rvar(1)($+1)='nonna'
   rvar('nonna')=rf('nonna')
end
 
endfunction
