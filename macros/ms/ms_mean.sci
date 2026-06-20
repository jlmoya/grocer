function r=ms_mean(grocer_endo,grocer_MS_M,grocer_MS_M_V,grocer_MS_var_opt,varargin)
 
// PURPOSE: estimate a Markvov Switching (MS) mean-variance
// model by the maximum likelihood method
// ------------------------------------------------------------
// INPUT:
// * grocer_endo = 'endo=y1;...;yn' where y1,...,n are the
//   names of endogenous variables
// * grocer_MS_M = a scalar equal the # of states
// * grocer_MS_V = a scalar:
//    - 1 if the variance of the residuals is the same for all
//    states
//    - grocer_MS_M if the variance of the residuals differs
//    among the states
// * grocer_MS_var_opt = a scalar:
//    - 1 if the variance of residuals is heteroskedastic
//    - 2 if the variance of residuals is homoskedastic
//    - 3 if the variance of residuals is unconstrained
// * varargin = optional arguments which can be:
//    - 'datation=xx' where xx is the name of a series used as
//    an a priori datation (default: no a priori datation)
//    - 'transf=xx' where xx is either 'dem' if the user wants
//    all series to be demeaned or 'stu' if the user wants all
//    series to be studentized (default: no transformation)
//    - 'gdelta=xx' where xx is a number used to calculate the
//    numerical derivative of the log-likelihood (default 1e-4)
//    - 'hdelta=xx' where xx is a number used to calculate the
//    numerical hessian (default 1e-5)
//    - 'prt=xx' where xx='nothing', 'final', 'all' or
//    ['initial';'final'] if the user wants to print nothing,
//    only the final results or the final and the initial
//    results
//    - 'noprint' if the user wants to print nothing (equivalent
//    to 'prt=nothing')
//   - 'dropna' if the user wants to remove the NA values
//     from the data
//   - 'init_beta_id = xxx' where xxx is a vector of starting
//     values for the switching exogenous variables
//   - 'init_prob' = xxx' where xxx is a matrix of starting
//     values for the transition probabilities
//   - 'init_var' = xxx' where xxx is a matrix of starting
//     values for the variances
//    - 'notstat' if the user does not want to calculate the
//      Student statistics of the parameters
// ------------------------------------------------------------
// OUTPUT:
// r = a results tlist with:
// * r('meth') = model literal type ('ms mean' 'ms var' or
//   'ms regression')
// * r('typmod') = model numbered type
// * r('y') = a (T x K) matrix of original endogenous variables
// * r('ymat') = (T*K x 1) matrix of stacked endogenous
//   variables
// * r('xmat') = (T*K x sum(n_x)) matrix of switching exogenous
//   variables//
// * r('zmat') = the (T x M) matrix of -transformed- non
//   switching regressors
// * r('switching V') = a scalar:
//   - 1 if the variance does not switch with the states
//   - M if the variance switches with the states
// * r('var_opt') = a scalar:
//    - 1 if the variance of residuals is heteroskedastic
//    - 2 if the variance of residuals is homoskedastic
//    - 3 if the variance of residuals is unconstrained
// * r('nobs') = the # if observations
// * r('nendo') = the # of endogenous variables
// * r('nb_states') = the # of states
// * r('coeff') = the (np x 1) vector of parameters
// * r('llike') = the log-likekihood
// * r('grad') = the gradient at the solution
// * r('yhat') = the adjusted y
// * r('filtered resid') = the filtered residuals of the
//   regression
// * r('dll') = the degrees of freedom
// * r('prob_st') = the (M x 1) vector of egodic state
//   probabilities
// * r('ptrans') = the (M x M) matrix of transition
//   probabilities
// * r('sigma') = the (M*M_V x M) variance-covariance matrix of
//   the residuals
// * r('beta_id') = the (1 x sum(n_x)*M) vector of switching
//   parameters
// * r('beta_co') = the (1 x sum(n_z)) vector of non switching
//   parameters
// * r('inv_sigma') = the (K x K) inverse of the variance
//   matrix
// * r('det_inv_sigma') = the determinant of the inverse of the
//   variance matrix
// * r('filtered probs') = the (T x M) vector of filtered
//   probabilities
// * r('smoothed probs') = the (T x M) vector of smoothed
//   probabilities
// * r('n_x') = the (K x 1) vector of the numbers of switching
//   exogenous variables for each endogenous variable
// * r('n_z') = the (K x 1) vector of the numbers of non switching
//   exogenous variables for each endogenous variable
// * r('stderr') = the (np x 1) vector of coefficients standard
//   errors
// * r('hes. delta') = the numerical increment for the calculation
//   of the hessian matrix
// * r('tstat') = the (np x 1) vector of associated t-stats
// * r('pvalue') = the (np x 1) vector of associated p-values
// * r('covbeta') = the (np x np) variance-covariance matrix of
//   the parameters
// * r('corbeta') = the (np x np) correlation matrix of the
//   parameters
// * r('ptrans_tstat') = the (M x 1) vector of t-stats for the
//   transition probabilities
// * r('beta_id_tstat') = the (1 x n_x*K*M) vector of t-stats for
//   switching parameters
// * r('beta_co_tstat') = the (1 x n_z*K) vector of t-stats for
//   non switching parameters
// * r('sigma_tstat') = the (M*M_V x M) matrix of t-stats for the
//   variance-covariance matrix of the residuals
// * r('ptrans_pvalue') = the (M x M) matrix of t-stats for
//   transition probabilities
// * r('beta_id_pvalue') = the (1 x n_x*K*M) vector of t-stats for
//   switching parameters
// * r('beta_co_pvalue') = the (1 x n_z*K) vector of t-stats for
//   non switching parameters
// * r('sigma_pvalue') = the (M*M_V x M) matrix of t-stats for
//   the variance-covariance matrix of the residuals
// * r('smoothed resid') = the smoothed residuals of the
//   regression
// * r('namey') = the (n_y x 1) vector of names of the
//   endogenous variables
// * r('namex_id') = the name of the switching exogenous
//   variables = a vector of K 'const'
// * r('namex_co') = the [] vector of names of the non
//   switching exogenous variables
// * r('apriori') = a scalar
//   - 0 if there is no a priori datation
//   - 1 if there is an a priori datation
// * r('prests') = a boolean indicating whether there is are ts
//   in the regression
// * r('prests') = a boolean indicating whether there is are ts
//   in the regression
// * r('datation') = the a priori datation if any
// * r('namedat') = the name of the series used for an a priori
//   datation if any
// * r('bounds') = the bounds if there are ts in the regression
// * r('dropna') = boolean indicating if NAs have
//     been dropped
// * r('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
grocer_dropna=%f
grocer_MS_typmod=1
grocer_MS_apriori=%nan
grocer_MS_n_x=1;        // number of exogenous, switching variables (including intercept) _n_x=1 by default for this model
grocer_MS_n_z=1;        // number of exogenous, non-switching variables (including intercept) _n_z=1 by default for this model
grocer_transf='none'
grocer_gdelta = 1e-4
grocer_hdelta = 1e-5
grocer_prt='final'
grocer_init_beta_co=%f
grocer_init_beta_id=%f
grocer_init_var=%f
grocer_init_prob=%f
grocer_hessian=%t
grocer_optfunc='optimg'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],'',',100*%eps,1000',100*%eps)
 
if grocer_MS_M_V ~= 1 & grocer_MS_M_V ~= grocer_MS_M then
    error('arg 5 (# of switching variances) should be equal to 1 or arg 4 (# of states)')
end
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi2=strsubst(grocer_argi,' ','')
      if part(grocer_argi2,1:9) == 'datation=' then
         grocer_MS_apriori=1
         grocer_MS_datation=part(grocer_argi2,10:length(grocer_argi2))
      elseif part(grocer_argi2,1:7) == 'transf=' then
         grocer_transf=part(grocer_argi2,8:11)
      elseif part(grocer_argi2,1:7) == 'gdelta=' then
         execstr('grocer_'+grocer_argi2)
      elseif part(grocer_argi2,1:7) == 'hdelta=' then
         execstr('grocer_'+grocer_argi2)
      elseif part(grocer_argi2,1:4) == 'prt=' then
         grocer_argi=strsubst(grocer_argi,'=','=[''')+''']'
         grocer_argi=strsubst(grocer_argi,';',''';''')
         execstr('grocer_'+grocer_argi)
      elseif part(grocer_argi2,1:5) == 'init_' then
         execstr('grocer_'+grocer_argi)
      elseif grocer_argi2 == 'noprint' then
         grocer_prt='nothing'
      elseif part(grocer_argi2,1:7) == 'notstat' then
         grocer_hessian=%f
      elseif grocer_argi2 == 'dropna' then
         grocer_dropna=%t
      elseif part(grocer_argi2,1:9) == 'opt_func=' then
         grocer_optfunc=part(grocer_argi2,10:length(grocer_argi2))
      elseif part(grocer_argi2,1:12) == 'opt_nelmead=' then
         grocer_opt_optim('nelmead')=part(grocer_argi2,13:length(grocer_argi2))
      elseif part(grocer_argi2,1:10) == 'opt_optim=' then
         grocer_opt_optim('optim')=part(grocer_argi2,11:length(grocer_argi2))
      elseif part(grocer_argi2,1:10) == 'opt_optim_ineq=' then
            grocer_opt_optim('optim ineq')=part(grocer_argi2,16:length(grocer_argi))
      elseif part(grocer_argi2,1:10) == 'opt_convg=' then
         execstr('grocer_opt_optim(''convg'')='+part(grocer_argi2,11:length(grocer_argi2)))
      end
   end
end
 
if grocer_prt == 'all' then
   grocer_prt=['initial';'final']
end
 
if ~isnan(grocer_MS_apriori) then
   [grocer_y,grocer_namey,grocer_MS_refdate,grocer_namedat,grocer_prests,grocer_boundsvarb,grocer_nonna]=...
     explouniv(grocer_endo,grocer_MS_datation,[],['endogenous','apriori_datation'],%t,grocer_dropna)
   B=unique(grocer_MS_refdate)
   if size(B,1) ~= grocer_MS_M then
      write(%io(2),' ','(a)')
      error('number of sates in the model ('+string(grocer_MS_M)+') and in the a priori datation ('+string(size(B,1))+') do not match')
   end
else
   [grocer_y,grocer_namey,grocer_prests,grocer_boundsvarb,grocer_nonna]=explone(grocer_endo,[],'endogenous',%t,grocer_dropna)
end
 
[grocer_MS_T,grocer_MS_K]=size(grocer_y)
y_mat=matrix(grocer_y,grocer_MS_T*grocer_MS_K,1)
x = eye(grocer_MS_K,grocer_MS_K) .*. ones(grocer_MS_T,1);
z = []
nz=zeros(grocer_MS_K,1)
nx=ones(grocer_MS_K,1)
 
r=ms_estimate(y_mat,x,z,nx,nz,grocer_MS_typmod,grocer_MS_T,grocer_MS_M,grocer_MS_M_V,grocer_MS_var_opt,grocer_MS_apriori,...
or(grocer_prt == 'initial'),grocer_init_beta_id,grocer_init_beta_co,grocer_init_prob,grocer_init_var,grocer_hessian,grocer_optfunc,grocer_opt_optim)
 
r(1)($+1)='namey'
r(1)($+1)='namex_id'
r(1)($+1)='namex_co'
r(1)($+1)='apriori'
r(1)($+1)='prests'
 
r('namey')=grocer_namey
namex_id=['const']
for i=2:grocer_MS_K
   namex_id=[namex_id ; 'const']
end
r('namex_id')=namex_id
r('namex_co')=[]
r('apriori')=grocer_MS_apriori
r('prests')=grocer_prests
 
if ~isnan(grocer_MS_apriori) then
   r(1)($+1)='datation'
   r('datation')=grocer_MS_refdate
   r(1)($+1)='namedat'
   r('namedat')=grocer_namedat
end
 
if grocer_prests then
   r(1)($+1)='bounds'
   r('bounds')=grocer_boundsvarb
end
 
if or(grocer_prt == 'final') then
   prtms(r,%io(2))
   pltms_prob(r,'smoothed',3)
   pltms_resid(r)
   pltms_yyhat(r)
end
 
endfunction
