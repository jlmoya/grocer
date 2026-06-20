function [Sig_mat_t]= MSVAR_Vec_Cov_tstat(tstat,K,M,v_opt,M_V,n_x);
 
// PURPOSE: calculates the t-stats of the var-cov matrix of the
// residuals from a MSvar estimate
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
// * Sig_mat_t = the t-stats matrix of the var-cov matrix of
//   the residuals
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.
// http://bellone.ensae.net
// All rights reserved
 
 
//==== returns a (K, K*M_V) Sigma(S(t)) matrix such as Sigma= (Sigma_1 ~....~Sigma_M_V) ====//
 
start= M*(M-1)+ n_x*M;
 
// original syntax
//if v_opt ==1 then
// Heteroscedastic version : Sigma(S(t))== diag(Sigma(S(t))) //
//   KK=K;
//elseif v_opt==2;
// Homoscedastic version : Sigam(S(t))== s(S(t))*eye(K) //
//   KK=1;
//else
// v_opt==3 : Full covariance matrix Sigma(S(t)) //
//   KK=K*(K+1)/2;
//end
// replaced by the one that follows and that avoids
// if then ... else ... end conditions
 
KK=(v_opt-1)*(3-v_opt)+K*(v_opt-2)*((v_opt-3)/2+(K+1)*(v_opt-1)/4)
 
Sig_mat_t=ones(K,K*M_V)
 
c=tstat(start+1:start+KK*M_V,:);
M_aux=matrix(c,KK,M_V);// reshape_gauss is equivalent to matrix()' when the
                       // start and destination matrices have the same number of arg
 
if v_opt==3 then
   for j=1:M_V;
						
      aux_j=M_aux(:,j);
 
//Full covariance matrix Sigma(S(t)) //
      Sig_j_t=invvech(aux_j,K);
      Sig_mat_t(:,K*(j-1)+1:K*j)=Sig_j_t
   end
 
else //Diagonal covariance matrix Sigma(S(t)) //
   for j=1:M_V;
      aux_j=M_aux(:,j);
      Sig_j_t=diag(aux_j)
      Sig_mat_t(:,K*(j-1)+1:K*j)=Sig_j_t
   end
end
endfunction
