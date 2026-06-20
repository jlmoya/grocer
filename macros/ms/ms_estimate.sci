function res=ms_estimate(y_mat,x_mat,z_mat,nx,nz,grocer_MS_typmod,T,grocer_MS_M,grocer_MS_M_V,grocer_MS_var_opt,grocer_MS_apriori,grocer_prt,grocer_init_beta_id,grocer_init_beta_co,grocer_init_prob,grocer_init_var,grocer_hessian,grocer_optfunc,grocer_opt_optim)
 
// PURPOSE: estimate a MSVAR model by the maximum likelihood
// method
// ------------------------------------------------------------
// INPUT:
// * y_mat = (T*K x 1) matrix of stacked endogenous variables
// * x_mat = (T*K x sum(n_x)) matrix of switching exogenous
//   variables
// * z_mat = (T*K x sum(n_z)) matrix of non switching exogenous
//   variables
// * nx = (K x 1) vector, with nx(i)=# of switching exogenous
//   variables for edogenous i
// * nz = (K x 1) vector, with nz(i)=# of non switching
//   exogenous variables for edogenous i
// * grocer_MS_typmod= type of MS model
//   - 1: mean-variance switching model
//   - 2: MS VAR regime dependent model
//   - 3: MS VAR intercept regime dependent model
//   - 4: partially regime dependent MS regression model
//   - 5: regime dependent MS regression model
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
// * grocer_MS_apriori =
//    - %nan if there is no a priori datation
//    - 1 if there is an priori datation
// * grocer_prt = %t if the initial values of the parameters
//   are to be printed
// * grocer_init_beta_id = either starting values for the
//   coefficients of the switching variables (if the user has
//   given ones) or the boolean %f (if the user has not given
//   starting values)
// * grocer_init_beta_co = either starting values for the
//   coefficients of the non switching variables (if the user has
//   given ones) or the boolean %f (if the user has not given
//   starting values)
// * grocer_init_prob = either starting values for the
//   coefficients of the transition probabilities (if the user
//   has given ones) or the boolean %f (if the user has not
//   given starting values)
// * grocer_init_var = either starting values for the
//   coefficients of the variances (if the user has
//   given ones) or the boolean %f (if the user has not given
//   starting values)
// * grocer_hessian = %t or %f whether the user wants to calculate the
//   Student statistics or not
// * grocer_optfunc =  the name of the optimisation function
//   (optim or optimg)
// * grocer_opt_optim = a tlist, collecting the options to
//   the optimisation function
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
//   variables
// * r('zmat') = (T*K x sum(n_z)) matrix of non switching
//   regressors
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
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.
// http://bellone.ensae.net
// All rights reserved
 
grocer_MS_n_x=size(x_mat,2);
grocer_MS_n_z=size(z_mat,2);
 
if grocer_MS_M_V==1 then
   grocer_MS_MlikeMV=ones(1,grocer_MS_M)
else
   grocer_MS_MlikeMV=1
end
 
if grocer_MS_typmod == 1 then
   meth='ms mean'
elseif grocer_MS_typmod == 2 | grocer_MS_typmod == 3 then
   meth='ms var'
elseif grocer_MS_typmod == 4 | grocer_MS_typmod == 5 then
   meth='ms regression'
end
 
// Automatic Initialization ================================
[param] = MSVAR_SetInit(y_mat,x_mat,z_mat,nx,nz,T,grocer_MS_M,grocer_MS_var_opt,grocer_MS_M_V,grocer_MS_typmod,grocer_MS_apriori,grocer_init_beta_id,grocer_init_beta_co,grocer_init_prob,grocer_init_var);
 
if grocer_prt then
   write(%io(2),"Initial statistical moments and parameters",'(a)')
   MSVAR_PrintInit(param,grocer_MS_K,grocer_MS_M,grocer_MS_var_opt,grocer_MS_M_V,grocer_MS_n_x,grocer_MS_n_z);
end
 
// ====================Maximisation of Log Likelihood ====================  */
write(%io(2)," Optimization step, be patient ...",'(a)');
write(%io(2),' ','(a)')
write(%io(2),' ','(a)')
grocer_Vec_Mat_foo=MSVAR_Vec_Mat
 
[paramfin,likl1,grad] = MSVAR_MaxHmm(param,grocer_optfunc,grocer_opt_optim);
 
// recover the true values of the parameters
//parameter=MSVAR_Constraint(paramfin)
nbparam=size(paramfin,1);
dll=grocer_MS_T-nbparam;
 
// explode the vector of parameters into their various
// dimensions
[prob_st,ptrans,beta_id,beta_co,sigma,inv_sigma,det_inv_sigma]=...
MSVAR_Vec_Mat(paramfin,grocer_MS_K,grocer_MS_M,grocer_MS_var_opt,grocer_MS_M_V,grocer_MS_n_x,grocer_MS_n_z);
 
// recovers some useful output
[Likv,y_hat,resid,PR,PR_STT,PR_STL] = MSVAR_Filt(paramfin)
// calculate the smoothed probabilities and residuals
PR_smoo = MSVAR_smooth(PR_STT,PR_STL,ptrans);
smoo_res=zeros(grocer_MS_T,grocer_MS_K)
Mu=[x_mat,z_mat]*[beta_id ;(ones(1,grocer_MS_M) .*. beta_co)];
y=matrix(y_mat,grocer_MS_T,grocer_MS_K);
for temps=1:grocer_MS_T
   smoo_res(temps,:)= y(temps,:)-PR_smoo(temps,:)*(matrix(Mu(temps+[0:(grocer_MS_K-1)]*grocer_MS_T,:),grocer_MS_K,grocer_MS_M)');
end
 
AIC = -2*likl1+2*nbparam
BIC = -2*likl1+nbparam*log(grocer_MS_T*grocer_MS_K)
hq = -2*likl1+2*nbparam*log(log(grocer_MS_T*grocer_MS_K))
 
res=tlist(['results';'meth';'typemod';'y';'ymat';'xmat';'zmat';'switching V';...
'var_opt';'nobs';'nendo';'nb_states';'coeff';'llike';'aic';'bic';'hq';'grad';'yhat';'filtered resid';'dll';'prob_st';...
'ptrans';'sigma';'beta_id';'beta_co';'inv_sigma';'det_inv_sigma';'filtered probs';...
'smoothed probs';'n_x';'n_z';'stderr';'hes. delta';'tstat';'pvalue';'covbeta';'corbeta';...
'ptrans_tstat';'beta_id_tstat';'beta_co_tstat';'sigma_tstat';'ptrans_pvalue';...
'beta_id_pvalue';'beta_co_pvalue';'sigma_pvalue';'smoothed resid'],...
meth,grocer_MS_typmod,y,y_mat,x_mat,z_mat,grocer_MS_M_V,...
grocer_MS_var_opt,grocer_MS_T,grocer_MS_K,grocer_MS_M,paramfin,likl1,...
AIC,BIC,hq,grad,y_hat,resid,dll,prob_st,ptrans,sigma,beta_id,beta_co,inv_sigma,det_inv_sigma,...
PR_STT,PR_smoo,nx,nz);
 
res('stderr')=%nan*paramfin;
res('tstat')=%nan*paramfin;
res('pvalue')=%nan*paramfin;
res('covbeta')=%nan*ones(nbparam,nbparam);
res('corbeta')=%nan*ones(nbparam,nbparam);
res('beta_id_pvalue')=%nan*beta_id;
res('sigma_pvalue')=%nan*sigma;
res('ptrans_tstat')=%nan*ptrans;
res('beta_id_tstat')=%nan*beta_id;
res('beta_co_tstat')=%nan*beta_co;
res('beta_co_pvalue')=%nan*beta_co;
res('sigma_tstat')=%nan*sigma;
res('ptrans_pvalue')=%nan*ptrans;
 
if grocer_hessian then
   res=MSVAR_stderr(res,grocer_hdelta)
else
 
end
res('smoothed resid')=smoo_res
 
endfunction
