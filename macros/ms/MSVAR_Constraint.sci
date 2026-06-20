function c = MSVAR_Constraint(param)
 
// PURPOSE: creates a constrained parameter g=g(theta) to enter
// the likeliood function
// ------------------------------------------------------------
// INPUT:
// * param= a (np x 1) vector of unconstrainted parameter
// ------------------------------------------------------------
// OUTPUT:
// * c= a (np x 1) vector of constrainted parameter
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
 
M=grocer_MS_M
M_V=grocer_MS_M_V
K=grocer_MS_K
n_x=grocer_MS_n_x
n_z=grocer_MS_n_z
 
R=M-1;
c=param;
var_opt=grocer_MS_var_opt
 
//===========Constraining _M-1 transition  probabilities, the _M-th to sum to one========
 
Aux_p=matrix(c(1:M*R),M,R)'
B=exp(Aux_p);
Sum=ones(1,M)+sum(B,1); // sumc(B)'
aux_p=B ./ (ones(R,1) .*. Sum)
 
//===Constraining _M-1 transition  probabilities, not to be trapped to zero===
 
prob=[vecr(aux_p) 0.001*ones(R*M,1)];
c(1:R*M,1)= max(prob,'c') ;
 
//===============================Constraining Covariance components =======================
S=M*R+M*grocer_MS_n_x;
 
//if var_opt ==1 then KK=K;  //Heteroscedastic version : Sigma(S(t))== diag(Sigma(S(t))) */
//if var_opt==2 then KK=1;; //Homoscedastic version : Sigam(S(t))== s(S(t))*eye(K,K) */
//if var_opt==3 then KK=K*(K+1)/2// : Full covariance matrix Sigma(S(t)) */
 
KK=(var_opt-1)*(3-var_opt)+K*(var_opt-2)*((var_opt-3)/2+(K+1)*(var_opt-1)/4)
 
v=c(S+1:S+M_V*KK,:);
aux_v=matrix(v,M_V,KK)'
 
if var_opt==3 then ;
   for j =1:M_V;
 
      M_aux= xpnd1(aux_v(:,j),K);
      Diag_mat=diag(abs(diag(M_aux)));
      Rho_mat=M_aux-Diag_mat;
      Rho_mat=MSVAR_Rho_constraint(Rho_mat)+eye(K,K);  // Constraints the Matrix rij=rho_constraint(thetaij) and rii=1
      M_aux= Diag_mat*Rho_mat*Diag_mat;
      aux_v(:,j)=vech_gauss(M_aux);
   end
 
else;
//var_opt==2 or var_opt==1: heteroscedastic or homoscedastic case */
   aux_v=aux_v .^ 2;
 
end;
 
c(S+1:S+M_V*KK,:)=vecr(aux_v);
endfunction
