function [PR_trans_t,bet_t,delta_t,var_cov_t]=MSVAR_Vec_tstat(tstat,covbeta,PR_TR,K,M,var_opt,M_V,n_x,n_z);
 
// PURPOSE: Recovers the statistics associated to the final
// parameters of a MSvar model
// ------------------------------------------------------------
// INPUT:
// * tstat = a (np x 1) vector of estimated parameters
// * covbeta = a (np x np) variance-covariance matrix
// * PR_TR = a (M x M) matrix of transition probabilities
// * K = a scalar equal to the # of endogenous variables
// * M = a scalar equal to the # of states
// * var_opt = a scalar equal to the type of the variance of
//   residuals
// * M_V = a scalar indicating whether the variance switches or
//   not
// * n_x = the # of non switching exogenous variables
// * n_z = the # of switching exogenous variables
// ------------------------------------------------------------
// OUTPUT:
// * PR_trans_t = the (M x M) matrix of t-stat for the
//   transition probabilities
// * bet_t = a (n_x*K*M x 1) vector of t-stat for the switching
//   parameters
// * delta_t = a (n_z x K) matrix of t-stat for the non
//   switching parameters
// * var_cov_t = the (n_z x K*M) matirx of t-stats for the
//   variance matrix of the residuals
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.
// http://bellone.ensae.net
// All rights reserved
 
// Extracts the transition probability matrix (M,M)
// and the ergodic vector from the vector of parameters
 
PR_trans_t= MSVAR_Vec_Prob_tstat(covbeta,M);
 
// Extracts the beta matrix (n_x,K*M)  from the vector of
// parameters
 
bet_t=MSVAR_Vec_Beta(tstat,K, M, n_x)
 
// Extracts the Sigma covariance matrix (K,K*M) from the
// vector of parameters
 
[var_cov_t] =MSVAR_Vec_Cov_tstat(tstat,K,M,var_opt,M_V,n_x);
 
// Extracts the beta matrix (n_x,K*M) from the vector of
// parameters
 
delta_t=[]
if (grocer_MS_typmod == 3) | (grocer_MS_typmod==4) then
   KK=(var_opt-1)*(3-var_opt)+K*(var_opt-2)*((var_opt-3)/2+(K+1)*(var_opt-1)/4)
 
   i_start =M*(M-1)+ n_x*M + KK*M_V;
   i_end=i_start+n_z;
 
   delta_t=tstat(i_start+1:i_end,:);
end
 
endfunction
