function [Likv,y_hat,resid,PR,PR_STT,PR_STL] = MSVAR_Filt(parametr,y_mat,x_mat,z_mat,grocer_MS_M,grocer_MS_M_V,grocer_MS_var_opt,grocer_MS_typmod)
 
// PURPOSE: computes, thanks to the Kittagawa-Hamilton Filter,
// filtered probabilities P(S(t)=i|I(t)) and P(P(S(t)=i|I(t-1))
// and subproduct such as mu_mean=E(y(t)) which are also useful
// to compute smoothed  probabilities.  Parametr is a vector of
// unconstrained transition martix probabilities
// ------------------------------------------------------------
// INPUT:
// parametr = a (np x 1) vector of parameters
// ------------------------------------------------------------
// OUTPUT:
// * Likv = a scalar equal to the log-likelihood of the model
// * y_hat = a (T x k) matrix of estimated y
// * resid = a (T x k) matrix of residuals
// * PR = a (T x 1) vector of conditional likelihood
// * PR_STT = a (T x M) matrix of filtered probabilities of
//   each state at each date
// * PR_STL = a (T x M) matrix of filtered probabilities of
//   each state at each date, condtionned by the y at date t
// ------------------------------------------------------------
// REFERENCES:
// * Benoit BELLONE: "Classical Estimation of Multivariate
//  Markov-Switching Models using MSVARlib", (2005).
// available at http://bellone.ensae.net
// e-mail: benoit.bellone@ensae.org
// * Adapated courtesy of Hamilton (1989), Hamilton (1994) 			
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
n_x=size(x_mat,2)
n_z=size(z_mat,2)
M=grocer_MS_M
M_V=grocer_MS_M_V
if grocer_MS_M_V==1 then
   grocer_MS_MlikeMV=ones(1,grocer_MS_M)
else
   grocer_MS_MlikeMV=1
end
 
T=grocer_MS_T
K=grocer_MS_K
[PROB_ST, PR_TR, beta_mat,delta_mat,var_mat,inv_var_mat,det_inv_var_mat]=...
grocer_Vec_Mat_foo(parametr,K,M,grocer_MS_var_opt,grocer_MS_M_V,n_x,n_z);
 
//==============================Some information about the intermediate constrained output ==============================
//
// PR_TR (_M,_M), matrix of transition probability (pij)
// PR_ergodic(_M,1), vector of ergodic probabilities (pj)
// beta_mat(_n_x,grocer_MS_K*_M), matrix of conditional regressor (beta(s)(k,j))
// delta_mat(_n_z,grocer_MS_K*M), matrix of unconditional regressor (delta(k,j))
// var_mat (grocer_MS_K,grocer_MS_K*_M) covariance matrix of conditional residuals
// inv_var_mat  (grocer_MS_K,grocer_MS_K*_M) inverse of the covariance matrix of conditional residuals
// det_inv_var_mat  (1,_M) determinant of  the inverse of the covariance matrix of conditional residuals
 
//======================================================================================================================
 
 
PR=ones(T,1);
PR_STT= ones(T,M);
PR_STL= PR_STT;
y_hat=ones(T,K);
 
Mu=[x_mat , z_mat]*[beta_mat ; (ones(1,M) .*. delta_mat)];
y=ones(1,M) .*. y_mat;
Res=y - Mu
 
// grocer_MS_likeMV is equal to 1 if M_V ==1 and to
// ones(1,M) if M_V~=1
Sig=grocer_MS_MlikeMV .*. inv_var_mat;
Det_Sig=(grocer_MS_MlikeMV .*. det_inv_var_mat)';
eta=zeros(M,1)
etamin=sqrt(%eps)*ones(M,1)
 
for temps=1:T
 
   for i=1:M
      M_aux=Res(temps+[0:(K-1)]*T,i)
      eta(i)=(1/sqrt(2*%pi))^(K)*sqrt(Det_Sig(i)) * exp(-0.5*M_aux'*Sig(:,1+(i-1)*K:i*K)*M_aux);
   end
   eta=max([real(eta) etamin],'c')
   PROB_DD = PR_TR * PROB_ST;
   PR_STL(temps,:)=PROB_DD';       // Probability: P(S(t)=i,Y(t)|I(t-1))=PR_STL
 
   PR_VL = eta .* PROB_DD     // PR_VL = (1 ./SQRT(2.*PI))^(grocer_MS_K).*sqrt(det_inv_var_mat).*EXP(-0.5.*AUX_M).*PROB_DD;
   //I remind the "univariate version": PR_VL = (1 ./SQRT(2.*PI.*VAR_L)).*EXP(-0.5*F.*F./VAR_L).*PROB_DD;
 
   PR_VAL =  sum(PR_VL,'r');       // Probability: PR_VAL = P(Y(t)|I(t-1))
          	
   PROB_ST = PR_VL/PR_VAL;    // Probability: PROB_ST = P(S(t)=i|I(t))
 
   PR(temps,:)=PR_VAL;
   PR_STT(temps,:)=PROB_ST';
   y_hat(temps,:)= PR_STT(temps,:)*(matrix(Mu(temps+[0:(K-1)]*T,:),K,M)'); // Simulated series
 
end
 
resid = matrix(y_mat,T,K) - y_hat;     // Residual
 
Likv= real(-sum(log(PR)));
 
endfunction
