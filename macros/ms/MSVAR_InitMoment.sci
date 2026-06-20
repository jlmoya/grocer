function [mu_out,cov1,cov3] = MSVAR_InitMoment(y_mat,apriori,M,M_V,var_opt,init_beta_id,init_beta_co,init_var);
 
// PURPOSE: Initialization of the Model Mean-Variance:
// y(t)=B(s(t))+u(t)
// (Optional: uses a priori reference date _ref_data)
// ------------------------------------------------------------
// INPUT:
// * y_mat = a (T x N) matrix
// * apriori = a 0-1 variable indicating whether there is an a
//   priori datation
// * M = # of states
// ------------------------------------------------------------
// OUTPUT:
// * mu_out = a (K x 1) vector of means for each state or
// * cov1_witch = a (K x M) matrix of
// * cov3_witch = a (K x M) matrix of
// * cov1 = a (K x M) matrix of
// * cov3 = a (K+K*(K-1)/2,M) matrix of
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.
// http://bellone.ensae.net
// All rights reserved
 
K=size(y_mat,2);
 
[n_sort,bench]=MSVAR_Index(y_mat,apriori,M);
y_sort=MSVAR_Sort(y_mat,bench);
 
mu=zeros(K,M);
res=y_sort
N=rows(y_sort);
i=1;
n_end=0;
 
cov1=zeros(K,M);
cov3=zeros(K+K*(K-1)/2,M)
 
for i=1:M
   n_start=n_end+1;
   n_end=n_sort(i,1);
 
   Aux=y_sort(n_start:n_end,:);
   [mean_init,med_init,sigma_init,cov_init,corr_init]=MSVAR_Stat(Aux);
   mu(:,i)=mean_init';
 
end
 
cov_tot=varcov0(y_mat)
corr_tot=var2cor(cov_tot)
 
 
if typeof(var_init) == boolean' then
 
   select var_opt
   case 1 then
      if M_V == M then
         [mean_init,med_init,sigma_init,cov_init,corr_init]=MSVAR_Stat(Aux);
         cov=zeros(K,M)
         for i=1:M
            cov(:,i)=sqrt(abs(diag(cov_init)));
         end
      else
         cov1=sqrt(abs(diag(cov_tot)));
      end
 
   case 2 then
      if M_V == M then
         cov=zeros(1,M)
         for i=1:M
            cov(i)=mean0(sqrt(abs(diag(cov_init))));
         end
      else
         cov1=sqrt(abs(diag(cov_tot)));
      end
      cov(:,i)=mean0(sqrt(abs(diag(cov_init))),1)';
 
   case 3 then
      Aux=MSVAR_Rho_inv(corr_init);
 
      // Constrained matrix (thetaii=exp2(sqrt(ln(sigma)) and thetaij=Rho_inv(rij) */
 
      Aux=Aux-matmul(diag(Aux),eye(K,K))+matmul(sqrt(abs(diag(cov_init))),eye(K,K));
      cov(:,i)=vech(Aux);
   end
end
 
if  var_opt==1 then
// Heteroscedastic Variance
   var_cov=cov1
 
elseif var_opt==2 then
// Var_opt=2 : Homoscedastic Variance
   var_cov=mean0(cov1,1)';
 
else
// Var_opt=3 : Full Matrix
   var_cov=cov3
end;
 
if M_V == 1 then
   cov1=sqrt(abs(diag(cov_tot)));
   aux=corr_tot - matmul(diag(corr_tot),eye(K,K))+matmul(cov1,eye(K,K));
   cov3=vech_gauss(aux);
end
 
if typeof(init_var) ~= 'boolean' then
   cov1=sqrt(abs(diag(init_var)))
end
 
if typeof(init_beta_id) == 'boolean' then
   mu_out=mu';  // Caution : we send back mu_out' rather than mu_out !*/
else
   mu_out=init_beta_id
end
 
endfunction
