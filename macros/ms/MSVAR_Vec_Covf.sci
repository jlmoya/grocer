function [Sig_mat, inv_Sig_mat, det_inv_Sig_mat]= MSVAR_Vec_Covf(param,K,M,v_opt,M_V,n_x);
 
// PURPOSE: converts a vector of parameters conditionnal Var-Cov
// into matrices Sigma(S), (K,K)
// ------------------------------------------------------------
// INPUT:
// * param = a (np x 1) vector of aprameters
// * K = # of endogenous variables
// * M = # of states
// * v_opt = the option for the type of variance matrix
//   v_opt =1 ==> heteroscedastic version
//   v_opt =2 ==> Homoscedastic version
//   v_opt =3 ==> Full covariance matrix
// * M_V = 1 if there is no switching parameter, M if there are
//   switching parameters
// * n_x = # of exogenous switching variables
// ------------------------------------------------------------
// OUTPUT:
// * Sig_mat = the variance matrix of the residuals
// * inv_Sig_mat = the inverse of variance matrix
// * det_inv_Sig_mat = the determinant of the inverse of
//   variance matrix
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.
// http://bellone.ensae.net
// All rights reserved
 
 
//==== returns a (K, K*M_V) Sigma(S(t)) matrix such as Sigma= (Sigma_1 ~....~Sigma_M_V) ====//
 
start= M*(M-1)+ n_x*K*M;
 
// original syntax
//if v_opt ==1 then
// Heteroscedastic version : Sigma(S(t))== diag(Sigma(S(t))) //
//   KK=K;
//elseif v_opt==2;
// Homoscedastic version : Sigma(S(t))== s(S(t))*eye(K) //
//   KK=1;
//else
// v_opt==3 : Full covariance matrix Sigma(S(t)) //
//   KK=K*(K+1)/2;
//end
// replaced by the one that follows and that avoids
// if then ... else ... end conditions
 
KK=(v_opt-1)*(3-v_opt)+K*(v_opt-2)*((v_opt-3)/2+(K+1)*(v_opt-1)/4)
 
Sig_mat=ones(K,K*M_V)
inv_Sig_mat=ones(K,K*M_V)
det_inv_Sig_mat=ones(1,M_V)
 
c=param(start+1:start+KK*M_V);
M_aux=matrix(c,KK,M_V);
 
if v_opt==3 then
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
 
endfunction
