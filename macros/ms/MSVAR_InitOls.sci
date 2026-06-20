function [beta_id_out,beta_co_out,cov1,cov3]=MSVAR_InitOls(y_mat,x_mat,z_mat,M,typmod,apriori,M_V,init_beta_id,init_beta_co,init_var);
 
// PURPOSE: intializes a  one step MS-OLS model following:
// y(t)=x(t).Beta_S(t)+u(t)
// or
// y(t) =x(t).Beta_S(t)+z(t).delta+u(t)
// ------------------------------------------------------------
// INPUT:
// * ymat = (T x K) matrix of endogenous variables
// * xmat = (T x n_x) matrix of non switching exogenous variables
// * zmat = (T x n_z) matrix of switching exogenous variables
// * M = # of states
// * typmod = a scalar indicating the type of the MS-VAR model
// * apriori = a (T x 1) vector equal to an a priori datation
//   of the states
// ------------------------------------------------------------
// OUTPUT:
// * beta_id_out = (T x n_x*M) matrix of starting values for the
//   switching coefficients
// * beta_co_out = (T x n_z*M) matrix of starting values for the
//   non switching coefficients
// * cov1_switch = a (K x M) matrix of variances of residuals
//   for each state
// * cov3_switch = a (K x M) matrix of vectorized matrix of
//   var-cov of the residuals for each state
// * cov1 = a (K x 1) matrix of unconditional variances of
//   residuals
// * cov3 = a (K x M) matrix of vectorized matrix of
//   unconditional var-cov of the residuals
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.
// http://bellone.ensae.net
// All rights reserved
 
 
K=size(y_mat,2);
n_x=size(x_mat,2);
n_z=size(z_mat,2);
y_M= [y_mat x_mat z_mat];
 
[n_sort,bench]=MSVAR_Index(y_M,apriori,M);
yy_sort=MSVAR_Sort(y_M,bench);
 
y_sort=yy_sort(:,1:K)
x_sort=yy_sort(:,K+1:K+n_x)
z_sort=yy_sort(:,K+n_x+1:K+n_x+n_z);
 
//============Switch case ============
beta_id_out=zeros(n_x,K*M);
beta_co_out=zeros(n_z,K);
A=[]
B=[]
y=[]
u_star=[];
rows_i=zeros(M,2);  // rows_i(:,1)= T_i and rows_i(:,2)=relevant index for a vectorialized matrix of regressors */
N=size(y_sort,1);
sum_i=0;
n_end=0;
 
for i=1:M;   //generates a suitable vectorialized  model y=x*beta */
 
   n_start=n_end+1;
   n_end=n_sort(i,1);
 
   yy_i=yy_sort(n_start:n_end,:);
   T_i=size(yy_i,1);
 
   y_i=yy_i(:,1:K);
   x_i=yy_i(:,K+1:K+n_x);
   z_i=yy_i(:,K+n_x+1:K+n_x+n_z);
   XX_i=eye(K,K) .*. x_i;
   ZZ_i=eye(K,K) .*. z_i;
   A=[A ; zeros(T_i*K,n_x*K*(i-1)) XX_i zeros(T_i*K,n_x*K*(M-i))];
 
   B=[B;ZZ_i];
   y=[y;vec(y_i)];
 
   sum_i=sum_i+T_i*K;
   rows_i(i,:)=[T_i sum_i];
 
end;
 
if (typmod==1) |(typmod==2) | (typmod==5) then;         //========= MS OLS - Mix models ======
   x=A;
elseif (typmod==3) | (typmod==4)  then;	   //========= MS OLS  models 3 and 4, : pure switch models  ========
   x=[A B];
else;
   error("Break error in InitOls");
end
 
if typeof(init_beta_co) == 'constant' & typeof(init_beta_id) == 'constant' then
// all coefficients are given
   beta_id_out=init_beta_id
   beta_co_out=init_beta_co
   bet=[matrix(init_beta_id,-1,1) ; matrix(init_beta_co,-1,1)]
 
elseif typeof(init_beta_co) == 'constant' then
// the commun coefficients are given; the idiosyncratic ones must
// therefore be estimated
   beta_co_out=init_beta_co
   ytransf=y-B*matrix(init_beta_co,-1,1)
   bet=[invxpx(A)*A'*ytransf ; matrix(init_beta_co,-1,1)]
 
elseif typeof(init_beta_id) == 'constant' then
// the idiosyncratic coefficients are given; the commun ones must
// therefore be estimated
   beta_co_id=init_beta_id
   ytransf=y-A*matrix(init_beta_id,-1,1)
   bet=[matrix(init_beta_id,-1,1) ; invxpx(B)*B'*ytransf]
 
else
   bet=invxpx(x)*x'*y
 
end
 
u=y-x*bet;
 	
//beta_id_out=(reshape_gauss((beta(1:n_x*K*M,:))',K*M,n_x))';
beta_id_out=(matrix((bet(1:n_x*K*M,:))',n_x,K*M))
 
if (typmod==3) | (typmod==4) then;
   beta_co_out=matrix((bet(n_x*K*M+1:n_x*K*M+n_z*K,:))',n_z,K)
end;
 
n_end=0;
 
if M_V == M then
   cov1=zeros(K,M);
   cov3=zeros(K+K*(K-1)/2,M);
   for i=1:M;
      if typeof(init_var) == 'boolean' then
         n_start=n_end+1;
         n_end=rows_i(i,2);
 
         u_i=u(n_start:n_end,:);
         T_i=rows_i(i,1);
         u_out=matrix(u_i',T_i,K)
         u_star=[u_star;u_out];
 
         cov_init=varcov0(u_out);
 
      else
         cov_init=init_var(i)
         if min(size(cov_init)) == 1 then
            if max(size(cov_init)) == 1 then
               cov_init=cov_init*eye(K,K)
            else
               cov_init=diag(cov_init)
            end
         end
      end
      corr_init=var2cor(cov_init);
      Aux=corr_init-matmul(diag(corr_init),eye(K,K));
      Aux=MSVAR_Rho_inv(Aux)+matmul(sqrt(abs(diag(cov_init))),eye(K,K));
      // Constrained matrix (thetaii=sqrt(sigma^2) and thetaij=Rho_inv(rij) */
 	
      cov1(:,i)=sqrt(abs(diag(cov_init)));
      cov3(:,i)=vech(Aux);
 
   end;
 
else
//============No switch case for Covariance ============
 
   if typeof(init_var) == 'boolean' then
      for i=1:M;
         n_start=n_end+1;
         n_end=rows_i(i,2);
 
         u_i=u(n_start:n_end,:);
         T_i=rows_i(i,1);
         u_out=matrix(u_i',T_i,K)
         u_star=[u_star;u_out];
      end
      cov_tot=mvvacov(u_star);
 
   else
     cov_tot=init_var
     if min(size(init_var)) == 1 then
         if max(size(init_var)) == 1 then
            cov_tot=init_var*eye(K,K)
         else
            cov_tot=diag(cov_tot)
         end
      end
   end
 
   corr_tot=var2cor(cov_tot);
 
   d=sqrt(abs(diag(cov_tot)));
   aux=corr_tot - matmul(diag(corr_tot),eye(K,K))+matmul(d,eye(K,K));
 
   cov1=d;
   cov3=vech(aux);
end
 
endfunction
