function [rsur]=surregu(grocer_namecoef,grocer_speccara,grocer_speccarb,grocer_crit,grocer_dropna,varargin)
 
// PURPOSE: provide Zellner Seemingly Unrelated Regression in
// the standard case when all equations are estimated on the
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
// * varargin = equations written
// * grocer_drpna = 'dropna' if the user wants to remove the
//     NA values from the data
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
// - rsur('bounds') = the bounds of all equations
// - rsur('dropna') = boolean indicating if NAs had
//		    been dropped
// - rsur('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2006-2007
// http://grocer.toolbox.free.fr/grocer.html
 
// explode the equation into the x,y matrices, the name of the
// endogenous variables, the list of indexes of the coefficients
// in each equation and the bounds and the boolean indicating
// the presence of a ts
 
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
 
[grocer_y,grocer_namey,grocer_prests,grocer_boundsvarb,grocer_nonna]=explone(varargin,[],'endogenous',%t,grocer_dropna)
grocer_nobs=size(grocer_y,1)
grocer_X=zeros(grocer_nobs*grocer_neqs,grocer_ncoeffs)
 
for grocer_j=1:grocer_ncoeffs
   execstr(grocer_namecoef(grocer_j)+'=-1')
   for grocer_i=1:grocer_neqs
      execstr('grocer_eqj='+varargin(grocer_i))
      if typeof(grocer_eqj) == 'ts' then
         grocer_eqj=series(grocer_eqj)-grocer_y(:,grocer_i)
      else
         grocer_eqj=grocer_eqj-grocer_y(:,grocer_i)
      end
      if or(grocer_eqj ~= 0) then
         grocer_listcoef(grocer_i)=[grocer_listcoef(grocer_i) ; grocer_j]
         grocer_ncoefeqs(grocer_i)=grocer_ncoefeqs(grocer_i)+1
         grocer_X(1+(grocer_i-1)*grocer_nobs:grocer_i*grocer_nobs,grocer_j)=grocer_eqj
      end
   end
   execstr(grocer_namecoef(grocer_j)+'=0')
end
 
rsur=sur1(grocer_y,grocer_X,grocer_crit,grocer_itmax)
 
rsur('prests')=grocer_prests
rsur('dropna')=grocer_dropna
rsur('namecoef')=grocer_namecoef
rsur('namey')=grocer_namey
rsur('eqs')=varargin
rsur('coefs')=grocer_listcoef
if grocer_prests then
   rsur(1)($+1) = 'bounds'
   rsur('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rsur(1)($+1)='nonna'
   rsur('nonna')=nonna
end
 
endfunction
