function [PR_ergodic,PR_trans,bet,delta,Sig_mat,inv_Sig_mat,det_inv_Sig_mat]=MSVAR_Vec_Matf(param,K,M,var_opt,M_V,n_x,n_z);
 
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
 
A=param(1:M*(M-1),1)
Aux_p=matrix(A,M,M-1)';
PR_trans=[Aux_p ; 1-sum(Aux_p,'r')]
 
PR_ergodic=MSVAR_Ergodic(PR_trans,M);
 
// Extracts the beta matrix (n_x,K*M)  from the vector of
// parameters
 
i_start =M*(M-1);
i_end=i_start+n_x*M;
// if the beta vector is empty, then set it to 0
// (to deal with the new beahviour introduced in Scilab 6.0:
//  x+[]=[] instaed of x+[]=x)
//if nx ==0 then
//   bet=[]
//else
   c=param(i_start+1:i_end);
   bet=matrix(c,n_x,M)
//end
 
// Extracts the Sigma covariance matrix (K,K*M) from the
// vector of parameters
 
start= M*(M-1)+ n_x*M;
 
// original syntax
//if var_opt ==1 then
// Heteroscedastic version : Sigma(S(t))== diag(Sigma(S(t))) //
//   KK=K;
//elseif var_opt==2;
// Homoscedastic version : Sigam(S(t))== s(S(t))*eye(K) //
//   KK=1;
//else
// var_opt==3 : Full covariance matrix Sigma(S(t)) //
//   KK=K*(K+1)/2;
//end
// replaced by the one that follows and that avoids
// if then ... else ... end conditions
 
KK=(var_opt-1)*(3-var_opt)+K*(var_opt-2)*((var_opt-3)/2+(K+1)*(var_opt-1)/4)
 
Sig_mat=ones(K,K*M_V)
inv_Sig_mat=ones(K,K*M_V)
det_inv_Sig_mat=ones(1,M_V)
 
c=param(start+1:start+KK*M_V);
M_aux=matrix(c,KK,M_V);
 
if var_opt==3 then
   for j=1:M_V;
						
      aux_j=M_aux(:,j);
 
//Full covariance matrix Sigma(S(t)) //
      Sig_j=invvech(aux_j,K);
      inv_Sig_j=inv(Sig_j);
      Sig_mat(:,K*(j-1)+1:K*j)=Sig_j
      inv_Sig_mat(:,K*(j-1)+1:K*j)=inv_Sig_j
      det_inv_Sig_mat(j)=1/det(Sig_j)
   end
 
else //Diagonal covariance matrix Sigma(S(t)) //
 
   for j=1:M_V;
      aux_j=M_aux(:,j)
      Sig_j=diag(aux_j)*eye(K,K)
      inv_Sig_j=inv(Sig_j);     // inv_Sig_j=invpd(Sig_j); //
      Sig_mat(:,K*(j-1)+1:K*j)=Sig_j
      inv_Sig_mat(:,K*(j-1)+1:K*j)=inv_Sig_j
      det_inv_Sig_mat(j)=det(inv_Sig_j);
   end
end
 
// Extracts the delta matrix (n_z,K*M) from the vector of
// parameters
 
// Extracts the delta matrix (n_z,K*M) from the vector of
// parameters
// if the delta vector is empty, then set it to 0
// (to deal with the new beahviour introduced in Scilab 6.0:
//  x+[]=[] instaed of x+[]=x)
i_start =M*(M-1)+ n_x*M + KK*M_V;
//if n_z == 0 then
//   delta=[]
//else
   i_end=i_start+n_z;
   delta=param(i_start+1:i_end,:);
//end
 
endfunction
