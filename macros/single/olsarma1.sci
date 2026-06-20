function res=olsarma1(y,x,AR,MA,initown,bhat,optfunc,opt_optim)
 
// PURPOSE: perform the estimation of ols model with arma
// errores
// ------------------------------------------------------------
// INPUT:
// * y = dependent variable vector (nobs x 1)
// * x = independent variables matrix (nobs x nvar)
// * AR = a (nar x 1) or (1 x nar) string or real vector of
//   parameters corresponding to the AR part of the error
//   process
//     . if AR is a real then all parameters are estimated
//     . if AR is a string then all parameters with in AR
//     with an equality (such as '=0.5') are constrained to
//     the given value (0.5 in the example)
//     . if AR is a string then it can contain inequality
//    constraints; for instance '<0.5' indicates that coeff
//    must be lower than 0.5
//     . if initown is set to %F, then the user can give any
//     value to AR; only it size matters for the estimation
//     process
//    . if initown is set to %F,
// * MA = a (nmaf x 1) or (1 x nmaf) string or real vector of
//   corresponding to the AR part of the error, with the same
//   working as for AR
// * initown = a boolean indicating whether the program must
//   use the entered values for AR, MA as starting values
//  (%t if this is the case)
// * bhat = the starting values of the relation between y and x
//   (if initown is set to %t; in the other case, it can be
//   omitted; if given, it will be ignored)
// * optfunc =  the name of the optimisation function
//   (optim or optimg)
// * opt_optim = a tlist, collecting the options to
//   the optimisation function
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with
//   . res('meth')  = 'ols with arma errors'
//   . res('y')     = y data vector
//   . res('x')     = x data matrix
//   . res('nobs')  = # observations
//   . res('nvar')  = # variables
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
//   . res('dw')    = Durbin-Watson Statistic
//   . res('condindex') = multicolinearity cond index
//   . res('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . res('llike') = the log-likelihood
//   . res('AR') = the estimated AR part of the residuals
//   . res('MA') = the estimated MA part of the residuals
//   . res('tAR') = the t-statistics of the AR part of the
//     residuals
//   . res('tMA') = the t-statistics of the MA part of the
//     residuals
//   . res('pvalues AR') = the p-values of the AR part of the
//     residuals
//   . res('pvalues MA') = the p-values of the MA part of the
//     residuals
//   . res('V') = the estimated variance of the innovations of
//     the residuals
//   . res('AIC') = the value of the Akaïke Critrium
//   . res('BIC') = the value of the Schwarz Critrium
//   . res('grad') = the gradient at solution
//   . res('type') = the e4 type of the model
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009-2010
// http://grocer.toolbox.free.fr/grocer.html
 
select typeof(AR)
 
case 'list' then
   nart=length(AR)
else
   nart=size(AR,'*')
end
 
ind_AR=1:nart
 
if typeof(AR) == 'constant' then
   ARf=vec2col(AR)
 
else
   ARf=zeros(nart,1)
   for i=nart:-1:1
      if ~isempty(strindex(AR(i),'=')) then
         ind_AR(i)=[]
         execstr('ARf(i)='+strsubst(AR(i),'=',''))
      end
   end
 
end
 
nAR=size(ind_AR,2)
tAR=%nan*ARf
pval_AR=tAR
 
 
nmat=size(MA,'*')
ind_MA=1:nmat
 
if typeof(MA) == 'constant' then
   MAf=vec2col(MA)
 
else
   MAf=zeros(nmat,1)
   for i=nmat:-1:1
      if ~isempty(strindex(MA(i),'=')) then
         ind_MA(i)=[]
         execstr('MAf(i)='+strsubst(MA(i),'=',''))
      end
   end
 
end
nMA=size(ind_MA,2)
tMA=%nan*MAf
pval_MA=tMA
 
grocer_E4OPTION=sete4opt('vcond=lyap','var=fac');
if ~initown then
   bhat=ols0(y,x)
   resid=y-x*bhat
   theta0=varma1(resid,AR,[],MA,[],1,1,%t,optfunc,opt_optim)
end
 
grocer_E4OPTION=sete4opt('vcond=lyap','econd=auto','var=fac');
[grocer_e4_T,grocer_e4_r]=size(x)
grocer_e4_m=1
grocer_e4_delta=sqrt(%eps)
grocer_e4_deps = .00000001;
grocer_e4_MV = 1;
grocer_e4_userflag=0
grocer_e4_z=[y x]
grocer_e4_u0=[]
 
[Phi,Gam,E,H,D,C,Q,S,R]=olsarma2kalm(x,AR,MA)
[grocer_e4_theta,grocer_e4_theta2mat,grocer_e4_thetalab,grocer_e4param,grocer_e4_ineq,Phi,Gam,E,H,D,C,Q,S,R,mat2thet]=...
ss2param(Phi,Gam,E,H,D,C,Q,grocer_e4_r,grocer_e4_m,S,R)
 
theta1=[-theta0(1:nAR); theta0(nAR+1:$); bhat]
ineq=grocer_e4_ineq
ineq(1:nAR,1)=-grocer_e4_ineq(1:nAR,2)
ineq(1:nAR,2)=-grocer_e4_ineq(1:nAR,1)
 
if or(grocer_e4_ineq(:,1) ~= -%inf) | or(grocer_e4_ineq(:,2) ~= %inf) then
// there are inequality constraints
   for i=1:size(theta1,1)
      if theta1(i)< ineq(i,1) then
         theta1(i)=ineq(i,1)
      elseif theta1(i)> ineq(i,2) then
         theta1(i)=ineq(i,2)
      end
   end
   [f,thetaf,g] = optim(lfmod_gmod_103,'b',ineq(:,1),ineq(:,2),theta1);
else
// there is no inequality constraint
   select optfunc
   case 'optim' then
      execstr('[f,thetaf,g] = optim(lfmod_gmod_103,theta1'+opt_optim('optim')+')');
   case 'optimg' then
     [f,thetaf,g] = optimg(lfmod_103,lfmod_gmod_103,theta1,...
     opt_optim('optim'),opt_optim('nelmead'),opt_optim('convg'));
   else
      error('not an available optimisation function'+optfunc)
   end
end
 
bhat=thetaf(grocer_e4param.np-grocer_e4_r+1:grocer_e4param.np)
yhat=x*bhat
resid=y-yhat
sigu=resid'*resid
sige=sigu/grocer_e4_T
ser=sqrt(sige)
 
// calculate the smoothed variables into the matrices of the state-measure reprensentation
[x_T,P_T,z_T]=smooth_e4(thetaf,grocer_e4_theta2mat,grocer_e4_z,[])
grocer_E4OPTION('var')='unfactorized'
execstr(mat2thet)
 
[std,corrm,varm,Im] = imod(thetaf,grocer_e4_theta2mat,grocer_e4_z,0);
tstat=bhat ./ std(grocer_e4param.np-grocer_e4_r+1:grocer_e4param.np)
 
pvalue=zeros(grocer_e4param.np-grocer_e4_r+1,1)
df=grocer_e4_T-grocer_e4param.np
 
for i=1:grocer_e4_r
   pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
end
ediff = resid(2:grocer_e4_T)-resid(1:grocer_e4_T-1)
dw = ediff'*ediff/sigu
condindex=bkwols(x)
indcte=search_cte(x)
prescte=~isempty(indcte)
 
ARf(ind_AR)=-thetaf(1:nAR)
tAR(ind_AR)=ARf(ind_AR) ./ std(1:nAR)
for i=1:nAR
   pval_AR(ind_AR(i))=(1-cdft("PQ",abs(tAR(ind_AR(i))),df))*2
end
 
MAf(ind_MA)=thetaf(nAR+1:nAR+nMA)
tMA(ind_MA)=MAf(ind_MA) ./ std(nAR+1:nAR+nMA)
for i=1:nMA
   pval_MA(ind_MA(i))=(1-cdft("PQ",abs(tMA(ind_MA(i))),df))*2
end
 
V=thetaf($)
 
 
AIC = 2*(f+grocer_e4param.np)/grocer_e4_T
BIC = (2*f+grocer_e4param.np*log(grocer_e4_T))/grocer_e4_T
 
res=tlist(['results';'meth';'y';'x';'nobs';'nvar';'beta';'yhat';...
'resid';'vcovar';'sige';'sigu';'ser';'tstat';'pvalue';'dw';'condindex';...
'prescte';'llike';'AR';'MA';'tAR';'tMA';'pvalues AR';'pvalues MA';'V';...
'AIC';'BIC';'grad';'type'],...
'ols with arma errors',y,x,grocer_e4_T,grocer_e4_r,bhat,yhat,resid,varm,sige,sigu,ser,tstat,...
pvalue,dw,condindex,prescte,-f,ARf,MAf,tAR,tMA,pval_AR,pval_MA,V,AIC,BIC,g,7)
 
 
endfunction
