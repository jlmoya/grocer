function [PR_ergodic,PR_trans,bet,delta,Sig_mat,inv_Sig_mat,det_inv_Sig_mat]=MSVAR_Vec_Mat(param,K,M,var_opt,M_V,n_x,n_z);
 
// PURPOSE: Transforms a vector of parameters in transition
// probability and ergodic matrices, beta coefficient and
// var-cov matrices
// ------------------------------------------------------------
// INPUT:
// * param = a (np x 1) vector of parameters
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
// * PR_ergodic = the (M x 1) vector of ergodic probabilities
// * PR_trans = the (M x M) matrix of transition probabilities
// * bet = a (1 x n_x*K*M) vector of switching parameters
// * delta = a (n_z x K) matrix of non switching parameters
// * var_cov = the variance matrix of the residuals
// * inv_var_cov = the inverse of the variance matrix
// * det_var_cov = the determinant of the inverse of the
//   variance matrix
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.
// http://bellone.ensae.net
// All rights reserved
 
// Extracts the transition probability matrix (M,M)
// and the ergodic vector from the vector of parameters
 
PR_trans=MSVAR_Vec_Prob(param,M);
PR_ergodic=MSVAR_Ergodic(PR_trans,M);
 
// Extracts the beta matrix (n_x,K*M)  from the vector of
// parameters
// if the beta vector is empty, then set it to 0
// (to deal with the new beahviour introduced in Scilab 6.0:
//  x+[]=[] instaed of x+[]=x)
if n_x == 0 then
   bet=[]
else
   bet= MSVAR_Vec_Beta(param,K,M,n_x);
end
 
// Extracts the Sigma covariance matrix (K,K*M) from the
// vector of parameters
[Sig_mat, inv_Sig_mat, det_inv_Sig_mat]= MSVAR_Vec_Cov(param,K,M,var_opt,M_V,n_x);
 
// Extracts the delta matrix (n_z,K*M) from the vector of
// parameters
// if the delta vector is empty, then set it to 0
// (to deal with the new beahviour introduced in Scilab 6.0:
//  x+[]=[] instaed of x+[]=x)
if n_z == 0 then
   delta=[]
else
   delta=param($-n_z+1:$,:);
end
 
endfunction
