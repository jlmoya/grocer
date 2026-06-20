function prior=tvpvar_prior0(grocer_nlag,grocer_k_B0,grocer_k_A0,grocer_k_W,grocer_k_Q,grocer_k_S,grocer_endo,varargin)
 
// PURPOSE: from broad parameters entered by the user, provide
// the prior tlist needed by fucntion Hetero_TVP_VAR function
// ------------------------------------------------------------
// INPUT:
// * grocer_nlag = a scalar, the # of lags in the VAR
// * grocer_k_B0 = a scalar, the dilatation factor applied to
//   the variance of the VAR coefficients over the training
//   period to determine the variance of the prior of the VAR
//   coefficients
// * grocer_k_A0 = a scalar, the dilatation factor applied to
//   the variance of the coefficients of the contemporaneous
//   endogenous vraiables over the training
//   period to determine the variance of the prior of the
//   contemporaneous endogenous vraiables
// * grocer_k_W = a scalar, the dilatation factor applied,
//   squared, to (n+1) for the inverse Wishart prior of W
// * grocer_k_Q = a scalar, the dilatation factor applied,
//   squared, to (n+1) for the inverse Wishart prior of Q
// * grocer_k_S = a scalar, the dilatation factor applied,
//   squared, for the inverse Wishart prior of S
// * varargin = an optional argument, that can be:
//   - 'exo=list(exo1,..., exon) if the user wants to add
//   exogenous variables to the VAR, exoi then collects the
//   exogenous variables of equation i
//   - 'nocte' if the user does not want constants in the VAR
//   - 'dropna' if the user wants to drop NA values from the
//    data instead of generating an error
// ------------------------------------------------------------
// OUTPUT:
// r= a prior tlist with:
// * r('B_0_prmean') = the prior mean of the B_0 parameters
//   (time varying coefficients of the VAR)
// * r('B_0_prvar') = the prior variance of the B_0 parameters
// * r('A_0_prmean') = the prior mean of the A_0 parameters
//   (time varying coefficients of the contemporaneous
//   endogenous variables of the VAR equations)
// * r('A_0_prvar') = the prior variance of the A_0 parameters
// * r('Q_prmean') = the prior mean of the Q parameters
// * r('Q_prvar') = the prior variance of the Q parameters
// * r('W_prmean') = the prior mean of the W parameters
// * r('W_prvar') = the prior variance of the W parameters
// * r('S_prmean') = the prior mean of the W parameters
// * r('S_prvar') = the prior variance of the W parameters
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015
// http://grocer.toolbox.free.fr/grocer.html
 
 
grocer_dropna=%f
grocer_prt=%t
grocer_flagexo=%f
grocer_nocte = %t
 
grocer_nargin=length(varargin)
for grocer_i=1:grocer_nargin
 
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_st=strsubst(varargin(grocer_i),' ','')
 
      if part(grocer_st,1:4) == 'exo=' then
        grocer_indeq=strindex(varargin(grocer_i),'=')
        execstr('grocer_exo='+part(varargin(grocer_i),grocer_indeq+1:length(grocer_st)))
        grocer_flagexo=%t
 
      elseif grocer_st == 'nocte' then
         grocer_nocte = 'nocte'
 
      elseif grocer_st == 'dropna' then
         grocer_dropna = %t
      end
 
   else
      error(typeof(varargin(grocer_i))+': not a valid type in var')
   end
 
end
 
 
if grocer_flagexo then
    if typeof(grocer_exo)  == 'list' then
       [grocer_mats,grocer_names,grocer_prests,grocer_b,grocer_nonna]=explon(lstcat(grocer_endo,grocer_exo),['endogenous';'exogenous'+string(1:length(grocer_exo))'],[],%t,grocer_dropna,%f,[grocer_nlag;zeros(length(grocer_exo),1)])
       y=grocer_mats(1)
       [nobs_y,ny]=size(y)
       if length(grocer_exo) ~= ny then
          error('list of exoegnous varaibles should have the same length as the # of endogenous variables')
       end
       nz=zeros(ny,1)
       for i=1:ny
          zi=grocer_mats(i+1)
          nz(i)=size(zi,2)
       end
       ylag=mlagb(y,grocer_nlag)
       ylag=ylag(1+grocer_nlag:nobs_y,:)
       grocer_tau=nobs_y-grocer_nlag
       z=zeros(grocer_tau*ny,grocer_nlag*ny^2+sum(nz))
       ind_col=0
       for i=1:ny
          zi=grocer_mats(i+1)
          z(grocer_tau*(i-1)+1:grocer_tau*i,ind_col+[1:ny*grocer_nlag+nz(i)])=[ylag , zi(1:grocer_tau,:)]
          ind_col=ind_col+ny*grocer_nlag+nz(i)
       end
       y=y(1+grocer_nlag:grocer_tau+grocer_nlag,:)
   end
   [B0_OLS0,xpxi]=ols0(y(:),z)
   resid0=y(:)-z*B0_OLS0
   resid=matrix(resid0,grocer_tau,ny)
 
   sigma=real(resid'*resid) ./ sqrt((grocer_tau-grocer_nlag-nz)*(grocer_tau-grocer_nlag-nz)')
   sqrtsigma=sigma^(-0.5).*.eye(grocer_tau,grocer_tau)
   sqrtsigmax=sqrtsigma*z
   [B0_OLS,VB0_OLS]=ols0(sqrtsigma*y(:),sqrtsigmax)
   resid=matrix(y(:)-z*B0_OLS0,grocer_tau,ny)
 
else
   [y,namey,prests,boundsvarb,nonna]=explone(grocer_endo,[],['endogenous'],%t,grocer_dropna,%f,grocer_nlag)
   rvar=var1(y,grocer_nlag,[],grocer_nocte)
   grocer_tau=size(y,1)-grocer_nlag
   B0_OLS0=rvar('beta')
   B0_OLS=B0_OLS0(:)
   VB0_OLS=rvar('sigma') .*. rvar('xpxi')
   ny=size(y,2)
   resid=rvar('resid')
 
end
 
 
// calculate the a priori distibution for log(sigma) and S coefficients
A0_OLS=zeros(ny*(ny-1)/2,1)
VA0_OLS=zeros(ny*(ny-1)/2,ny*(ny-1)/2)
logsigma0=0.5*log(sum(resid(:,1).^2)/grocer_tau)
S_prmean=A0_OLS
for j=2:ny
   index=j-1+(j-3)*(j-2)/2:(j-1)*j/2
   res=ols2(resid(:,j),-resid(:,1:j-1))
   A0_OLS(index)=res('beta')
   VA0_OLS(index,index)=res('vcovar')*(res('nobs')-res('nvar'))/res('nobs')
   S_prmean(index,index)=grocer_k_S^2*j*VA0_OLS(index,index)
   logsigma0=[logsigma0 ; 0.5*log(res('sigu')/grocer_tau)]
end
 
prior=tlist(['prior';'B_0_prmean';'B_0_prvar';'A_0_prmean';'A_0_prvar';...
'logsigma_prmean';'logsigma_prvar';...
'Q_prmean';'Q_prvar';...
'W_prmean';'W_prvar';...
'S_prmean';'S_prvar'],...
B0_OLS,grocer_k_B0*VB0_OLS,A0_OLS,grocer_k_A0*VA0_OLS,...
logsigma0,eye(ny,ny),...
grocer_k_Q^2*grocer_tau*VB0_OLS,grocer_tau,...
grocer_k_W^2*(ny+1)*eye(ny,ny),(ny+1),...
S_prmean,[2:ny]...
)
 
endfunction
