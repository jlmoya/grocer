function [rsur]=suruneq(grocer_namecoef,grocer_speccara,grocer_speccarb,grocer_crit,grocer_dropna,varargin)
 
// PURPOSE: provide Zellner Seemingly Unrelated Regression in
// the standard case when all equations are not estimated on the
// same period (subroutine of function sur)
// ------------------------------------------------------------
// INPUT:
// * grocer_namecoef = the names of the coefficients
// * grocer_speccara = column vector of characters that must be
//   found after the name of a coefficient
// * grocer_speccarb = column vector of characters that must be
//   found before the name of a coefficient
// * grocer_crit = a scalar, the convergence criterion
//   (optional; default =1e-4)
// * grocer_drpna = 'dropna' if the user wants to remove the
//     NA values from the data
// * varargin = equations written
// 'vary=coef1*varx1+...+coefi*varxi'
//   where:
//   - coefi = the name of a coefficient
//   - varxi = the name of a variable
// ------------------------------------------------------------
// OUTPUT:
// rsur=a tlist with
// - rsur('meth') = 'sur'
// - rsur('nobs') = # of observations
// - rsur('neqs') = # of estimated equations
// - rsur('ncoef') = # of estimated coefficients
// - rsur('beta') = bhat
// - rsur('tstat') = t-stats
// - rsur('pvalue') = pvalue of the betas
// - rsur('sigma') = covariance matrix of the residuals
// - rsur('sigu') = (1 x neqs) sum of squared residuals
// - rsur('sigu') = (1 x neqs) sum of squared residuals
// - rsur('dw') = (1 x neqs) Durbin-Watson
// - rsur('prests') = boolean indicating the presence or
//     absence of a time series in the regression
// - rsur('namecoef') = (ncoef x 1) mame of the coeffcients
// - rsur('namey') = name of endogenous variables
// - rsur('eqs') = list of the neqs equations
// - rsur('coefs') = list of the coefs names in each equation
// - rsur('bounds') = list of the bounds in each equation
// - rsur('dropna') = boolean indicating if NAs had
//		    been dropped
// - rsur('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2006-2007
// http://grocer.toolbox.free.fr/grocer.html
 
 
grocer_eqs=varargin
grocer_neqs=length(varargin)
grocer_ncoeffs=size(grocer_namecoef,'*')
grocer_ncoefeqs=zeros(grocer_neqs,1)
for grocer_i=1:grocer_ncoeffs
   execstr(grocer_namecoef(grocer_i)+'=0')
end
grocer_listcoef=list()
for grocer_j=1:grocer_neqs
   varargin(grocer_j)=strsubst(varargin(grocer_j),'=','-(')+')'
   grocer_listcoef(grocer_j)=[]
end
 
// explode the equations over the longest possible period,
// foilling the non available oobservatiosn to %nan: this is
// done tjrough the option %f for testna (NA are ignored)
[grocer_y,grocer_namey,grocer_prests,grocer_boundsvarb,grocer_nonna]=explone(varargin,[],'endogenous',%f,%f)
grocer_nobs=size(grocer_y,1)
grocer_nobseq=zeros(grocer_neqs,1)
grocer_nonna=~isnan(grocer_y)
grocer_allnonna=and(grocer_nonna,'c')
grocer_indnonna_eqs=list()
 
grocer_indnonna=[]
for grocer_i=1:grocer_neqs
   grocer_nobseq(grocer_i)=sum(bool2s(grocer_nonna(:,grocer_i)))
   grocer_indnonna_eqs(grocer_i)=find(grocer_nonna(:,grocer_i))
   grocer_indnonna=[grocer_indnonna grocer_nobs*(grocer_i-1)+grocer_indnonna_eqs(grocer_i)]
end
 
grocer_X=zeros(grocer_nobs*grocer_neqs,grocer_ncoeffs)
 
// select the observations according to the y that have
// NA observations:
// - grocer_typeper finds the existing combinations of
//   NA values for a given observation
// - grocer_indtypes gives for each observation what combination
//   it belongs to
// - grocer_listypes gives for each combination the values of the
//   non NA y
grocer_typeper=unique(bool2s(grocer_nonna),'r')
grocer_indtypes=zeros(grocer_nobs,1)
for grocer_i=1:grocer_nobs
   grocer_j=1
   while or(bool2s(grocer_nonna(grocer_i,:)) ~= grocer_typeper(grocer_j,:))
      grocer_j=grocer_j+1
   end
   grocer_indtypes(grocer_i)=grocer_j
end
grocer_listtypes=list()
for grocer_i=1:size(grocer_typeper,1)
   grocer_listtypes($+1)=find(grocer_typeper(grocer_i,:) == 1)
end
 
// recognize the equation in which the coefficients appear
// and fill accordingly the X matrix
for grocer_j=1:grocer_ncoeffs
   execstr(grocer_namecoef(grocer_j)+'=-1')
   for grocer_i=1:grocer_neqs
      grocer_eqj=series(evstr(varargin(grocer_i)))-grocer_y(:,grocer_i)
      if or(grocer_eqj ~= 0 & ~isnan(grocer_eqj)) then
         grocer_listcoef(grocer_i)=[grocer_listcoef(grocer_i) ; grocer_j]
         grocer_ncoefeqs(grocer_i)=grocer_ncoefeqs(grocer_i)+1
         grocer_X(1+(grocer_i-1)*grocer_nobs:grocer_i*grocer_nobs,grocer_j)=grocer_eqj
      end
   end
   execstr(grocer_namecoef(grocer_j)+'=0')
end
 
common_obs=find(and(~isnan(grocer_y),'c'))
// rescale the y and the X matrix to have a correctly balanced sigma matrix
[y,scaley]=scalemat(grocer_y)
X=grocer_X ./(10 .^scaley' .*. ones(grocer_nobs,grocer_ncoeffs))
y=y(:)
resid=%nan*y
 
// uses results from ols as starting values
beta0=ols0(y(grocer_indnonna),X(grocer_indnonna,:))
resid(grocer_indnonna)=y(grocer_indnonna)-X(grocer_indnonna,:)*beta0
//nobs=ones(grocer_neqs,1)
 
sigma=zeros(grocer_neqs,grocer_neqs)
types_sqrtsigma=grocer_listtypes
sqrtom_y=y
sqrtom_X=X
convg=grocer_crit*2
nbit=0
grocer_yit=grocer_y
grocer_Xit=grocer_X
 
while (convg > grocer_crit & nbit < grocer_itmax) then
   nbit=nbit+1
   ind_per=0
   resid_mat=matrix(resid,grocer_nobs,-1)
   sigma=resid_mat(common_obs,:)'*resid_mat(common_obs,:)/grocer_nobs
   for i=1:size(grocer_typeper,1)
      types_sqrtsigma(i)=(real(sigma(grocer_listtypes(i),grocer_listtypes(i))))^(-0.5)
   end
   // build the sqrt(omega)*y and sqrt(omega)*X matrix
   for i=1:grocer_nobs
      sqrtom_y(i+grocer_nobs*(grocer_listtypes(grocer_indtypes(i))-1))=...
         types_sqrtsigma(grocer_indtypes(i))...
         *y(i+grocer_nobs*(grocer_listtypes(grocer_indtypes(i))-1))
      sqrtom_X(i+grocer_nobs*(grocer_listtypes(grocer_indtypes(i))-1),:)=...
         types_sqrtsigma(grocer_indtypes(i))...
         *X(i+grocer_nobs*(grocer_listtypes(grocer_indtypes(i))-1),:)
   end
   [bhat,ixpomegam1x]=ols0(sqrtom_y(grocer_indnonna),sqrtom_X(grocer_indnonna,:));
   resid=y-X*bhat
   convg=sum(abs(bhat-beta0))
   beta0=bhat
end
 
residl=list()
for i=1:grocer_neqs
   residl($+1)=resid(1+grocer_nobs*(i-1):grocer_nobs*i)*scaley
end
 
// rescale the sigma matrix to recover its true value
sigma=diag(10 .^scaley)*sigma*diag(10 .^scaley)
tstat=bhat ./ sqrt(diag(ixpomegam1x))
pvalue=zeros(grocer_ncoeffs,1)
ds=diag(sigma)
ser=sqrt(ds)
sigu=ds .* (grocer_nobs-grocer_ncoefeqs)
corm=var2cor(sigma)
 
for i=1:grocer_ncoeffs
   pvalue(i)=(1-cdfnor("PQ",abs(tstat(i)),0,1))*2
end
 
dw=zeros(1,grocer_neqs)
listbounds=list()
grocer_boundsvarnum=date2num(grocer_boundsvarb(1)):date2num(grocer_boundsvarb($))
for i=1:grocer_neqs
   dates=grocer_boundsvarnum(~isnan(grocer_y(:,i)))
   listbounds($+1)=dates
 
   // durbin-watson
   resid_i=residl(i)
   resid_i=resid_i(~isnan(resid_i))
   ediff = resid_i(2:$)-resid_i(1:$-1)
   dw(i) = ediff'*ediff/sigu(i)
 
end
 
rsur=tlist(['results';'meth';'nobs';'neqs';'ncoef';'beta';...
'tstat';'pvalue';'resid';'sigma';'corr';'sigu';'ser';'dw';...
'prests';'namecoef';'namey';'eqs';'coefs';'bounds'],...
'sur',grocer_nobseq,grocer_neqs,grocer_ncoefeqs,bhat,tstat,pvalue,...
residl,sigma,corm,sigu,ser,dw,grocer_prests,grocer_namecoef,...
grocer_namey,grocer_eqs,grocer_listcoef,listbounds)
 
if grocer_dropna then
   rsur(1)($+1)='nonna'
   rsur('nonna')=nonna
end
 
endfunction
