function grocer_res_inp=ms_mean_oos(grocer_res_inp,grocer_endo,varargin)
 
// PURPOSE: run out-of-sample an estimated Markov-switching
// VAR
//------------------------------------------------------------
// INPUT:
// * grocer_res_inp = a 'ms var' results tlist
// * grocer_endo =
//   - (T x K) string matrix of endogenous variables
//   or:
//   - a list containing all the endogenous variables in any of
//   the following form:
//     . a time series
//     . a real matrix
//     . a string representing such objects
//     . the string 'const' (for the constant variable)
// * varargin = optional arguments which can be:
//    - 'prt=xx' where xx='nothing', 'final', 'all' or
//    ['initial';'final'] if the user wants to print nothing,
//    only the final results or the final and the initial
//    results
//    - 'noprint' if the user wants to print nothing (equivalent
//    to 'prt=nothing')
//   - 'dropna' if the user wants to remove the NA values
//     from the data
//------------------------------------------------------------
// OUTPUT:
// grocer_res_inp = a results tlist with:
// * grocer_res_inp('meth') ='out of sample ms mean'
// * grocer_res_inp('typmod') = model numbered type
// * grocer_res_inp('y') = a (T x K) matrix of original
//   endogenous variables
// * grocer_res_inp('ymat') = (T*K x 1) matrix of stacked
//   endogenous variables
// * grocer_res_inp('xmat') = (T*K x sum(n_x)) matrix of
//   switching exogenous variables
// * grocer_res_inp('zmat') = the (T x M) matrix of
//   -transformed- non switching regressors
// * grocer_res_inp('switching V') = a scalar:
//   - 1 if the variance does not switch with the states
//   - M if the variance switches with the states
// * grocer_res_inp('var_opt') = a scalar:
//    - 1 if the variance of residuals is heteroskedastic
//    - 2 if the variance of residuals is homoskedastic
//    - 3 if the variance of residuals is unconstrained
// * grocer_res_inp('nobs') = the # of observations
// * grocer_res_inp('nendo') = the # of endogenous variables
// * grocer_res_inp('nb_states') = the # of states
// * grocer_res_inp('coeff') = the (np x 1) vector of
//   parameters
// * grocer_res_inp('llike') = the log-likekihood
// * grocer_res_inp('grad') = the gradient at the solution
// * grocer_res_inp('yhat') = the adjusted y
// * grocer_res_inp('filtered resid') = the filtered residuals
//   of the regression
// * grocer_res_inp('dll') = the degrees of freedom
// * grocer_res_inp('prob_st') = the (M x 1) vector of egodic
//   state probabilities
// * grocer_res_inp('ptrans') = the (M x M) matrix of
//   transition probabilities
// * grocer_res_inp('sigma') = the (M*M_V x M) variance-
//   covariance matrix of the residuals
// * grocer_res_inp('beta_id') = the (1 x sum(n_x)*M) vector of
//   switching parameters
// * grocer_res_inp('beta_co') = the (1 x sum(n_z)) vector of
//   non switching parameters
// * grocer_res_inp('inv_sigma') = the (K x K) inverse of the
//   variance matrix
// * grocer_res_inp('det_inv_sigma') = the determinant of the
//   inverse of the variance matrix
// * grocer_res_inp('filtered probs') = the (T x M) vector of
//   filtered probabilities
// * grocer_res_inp('smoothed probs') = the (T x M) vector of
//   smoothed probabilities
// * grocer_res_inp('n_x') = the (K x 1) vector of the numbers
//   of switching exogenous variables for each endogenous
//   variable
// * grocer_res_inp('n_z') = the (K x 1) vector of the numbers
//   of non switching  exogenous variables for each endogenous
//   variable
// * grocer_res_inp('stderr') = the (np x 1) vector of
//   coefficients standard errors
// * grocer_res_inp('hes. delta') = the numerical increment for
//   the calculation of the hessian matrix
// * grocer_res_inp('tstat') = the (np x 1) vector of
//   associated t-stats
// * grocer_res_inp('pvalue') = the (np x 1) vector of
//   associated p-values
// * grocer_res_inp('covbeta') = the (np x np) variance-
//   covariance matrix of the parameters
// * grocer_res_inp('corbeta') = the (np x np) correlation
//   matrix of the parameters
// * grocer_res_inp('ptrans_tstat') = the (M x 1) vector of
//   t-stats for the transition probabilities
// * grocer_res_inp('beta_id_tstat') = the (1 x n_x*K*M) vector
//   of t-stats for switching parameters
// * grocer_res_inp('beta_co_tstat') = the (1 x n_z*K) vector
//   of t-stats for non switching parameters
// * grocer_res_inp('sigma_tstat') = the (M*M_V x M) matrix of
//   t-stats for the variance-covariance matrix of the
//    residuals
// * grocer_res_inp('ptrans_pvalue') = the (M x M) matrix of
//   t-stats for transition probabilities
// * grocer_res_inp('beta_id_pvalue') = the (1 x n_x*K*M) vector
//   of t-stats for switching parameters
// * grocer_res_inp('beta_co_pvalue') = the (1 x n_z*K) vector
//   of t-stats for non switching parameters
// * grocer_res_inp('sigma_pvalue') = the (M*M_V x M) matrix of
//   t-stats for the variance-covariance matrix of the residuals
// * grocer_res_inp('smoothed resid') = the smoothed residuals
//   of the regression
// * grocer_res_inp('namey') = the (ny x 1) vector of names of
//   the endogenous variables
// * grocer_res_inp('namex_id') = the (n_x x 1) vector of names
//   of the switching exogenous variables
// * grocer_res_inp('namex_co') = the (n_x x 1) vector of names
//   of the non switching exogenous variables
// * grocer_res_inp('apriori') = a scalar
//   - 0 if there is no a priori datation
//   - 1 if there is an a priori datation
// * grocer_res_inp('prests') = a boolean indicating whether
//   there are ts in the regression
// * grocer_res_inp('prests') = a boolean indicating whether
//   there are ts in the regression
// * grocer_res_inp('datation') = the a priori datation if any
// * grocer_res_inp('namedat') = the name of the series used
//   for an a priori datation if any
// * grocer_res_inp('bounds') = the bounds if there are ts in
//   the regression
// * grocer_res_inp('dropna') = boolean indicating if NAs have
//     been dropped
// * grocer_res_inp('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// Copyright: Eric Dubois 20015
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_dropna=%f
grocer_prt='final'
grocer_nargin=length(varargin)
 
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi2=strsubst(grocer_argi,' ','')
      if part(grocer_argi2,1:4) == 'prt=' then
         grocer_argi=strsubst(grocer_argi,'=','=[''')+''']'
         grocer_argi=strsubst(grocer_argi,';',''';''')
         execstgrocer_res_inp('grocer_'+grocer_argi)
      elseif grocer_argi2 == 'dropna' then
         grocer_dropna=%t
      elseif grocer_argi2 == 'noprint' then
         grocer_prt='nothing'
      end
   end
end
 
grocer_Vec_Mat_foo=MSVAR_Vec_Mat
 
// retrieve useful parameters from the 'ms var' input results tlist
grocer_MS_K=grocer_res_inp('n_z')
grocer_MS_M=grocer_res_inp('nb_states')
grocer_MS_M_V=grocer_res_inp('switching V')
grocer_MS_var_opt=grocer_res_inp('var_opt')
grocer_param=grocer_res_inp('coeff')
grocer_MS_typmod=grocer_res_inp('typemod')
 
if grocer_MS_M_V==1 then
   grocer_MS_MlikeMV=ones(1,grocer_MS_M)
else
   grocer_MS_MlikeMV=1
end
 
[grocer_y,grocer_namey,grocer_prests,grocer_b,nonna]=explone(grocer_endo,[],'endogenous',%t,grocer_dropna)
 
[grocer_MS_T,grocer_MS_K]=size(grocer_y)
y_mat=matrix(grocer_y,grocer_MS_T*grocer_MS_K,1)
x = eye(grocer_MS_K,grocer_MS_K) .*. ones(grocer_MS_T,1);
z = zeros(grocer_MS_K*grocer_MS_T,1)
 
[Likv,y_hat,resid,PR,PR_STT,PR_STL] = MSVAR_Filt(grocer_param,y_mat,x,z,grocer_MS_M,grocer_MS_M_V,grocer_MS_var_opt,grocer_MS_typmod)
 
// calculate the smoothed probabilities and residuals
PR_smoo = MSVAR_smooth(PR_STT,PR_STL,grocer_res_inp('ptrans'));
smoo_res=zeros(grocer_MS_T,grocer_MS_K)
Mu=x*grocer_res_inp('beta_id');
y=matrix(y_mat,grocer_MS_T,grocer_MS_K)
for temps=1:grocer_MS_T
   smoo_res(temps,:)= y(temps,:)-PR_smoo(temps,:)*(matrix(Mu(temps+[0:(grocer_MS_K-1)]*grocer_MS_T,:),grocer_MS_K,grocer_MS_M)');
end
 
grocer_res_inp('meth')='out of sample ms mean'
grocer_res_inp('y')=y
grocer_res_inp('ymat')=y_mat
grocer_res_inp('xmat')=x
grocer_res_inp('zmat')=z
grocer_res_inp('nobs')=grocer_MS_T
grocer_res_inp('llike')=Likv
grocer_res_inp('yhat')=y_hat
grocer_res_inp('filtered resid')=resid
grocer_res_inp('dll')=grocer_MS_T-size(grocer_param,1)
grocer_res_inp('filtered probs')=PR_STT
grocer_res_inp('smoothed probs')=PR_smoo
grocer_res_inp('smoothed resid')=smoo_res
 
if grocer_dropna then
   if and(grocer_res_inp(1) ~= 'nonna') then
      grocer_res_inp($+1)='nonna'
   end
   grocer_res_inp('nonna')=nonna
end
 
if grocer_prests then
   if and(grocer_res_inp(1) ~= 'bounds') then
      grocer_res_inp($+1)='bounds'
   end
   grocer_res_inp('bounds')=grocer_b
end
 
if or(grocer_prt == 'final') then
   pltms_prob(grocer_res_inp,'smoothed',3)
   pltms_resid(grocer_res_inp)
   pltms_yyhat(grocer_res_inp)
end
 
endfunction
