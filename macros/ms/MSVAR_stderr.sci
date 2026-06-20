function res=MSVAR_stderr(res,hdelta)
 
// PURPOSE: from a MSVAR estimation, compute hessian, gradians,
// stdev, tstat, pvalues and print parameters, adapted courtesy
// of Thierry Roncalli (1995)
// ------------------------------------------------------------
// INPUT:
// * res = a results tlist from a Markov switching estimation
// * hdelta = a scalar, the increment used to calculate the
//   hessian matrix
// ------------------------------------------------------------
// OUTPUT:
// res = the initial results tlist with the following fields
// updated:
// * res('stderr') = the (np x 1) vector of coefficients standard
//   errors
// * res('tstat') = the (np x 1) vector of associated t-stats
// * res('pvalue') = the (np x 1) vector of associated p-values
// * res('covbeta') = the (np x np) variance-covariance matrix of
//   the parameters
// * res('corbeta') = the (np x np) correlation matrix of the
//   parameters
// * res('ptrans_tstat') = the (M x 1) vector of t-stats for the
//   transition probabilities
// * res('beta_id_tstat') = the (1 x n_x*K*M) vector of t-stats for
//   switching parameters
// * res('beta_co_tstat') = the (1 x n_z*K) vector of t-stats for
//   non switching parameters
// * res('sigma_tstat') = the (M*M_V x M) matrix of t-stats for the
//   variance-covariance matrix of the residuals
// * res('ptrans_pvalue') = the (M x M) matrix of t-stats for
//   transition probabilities
// * res('beta_id_pvalue') = the (1 x n_x*K*M) vector of t-stats for
//   switching parameters
// * res('beta_co_pvalue') = the (1 x n_z*K) vector of t-stats for
//   non switching parameters
// * res('sigma_pvalue') = the (M*M_V x M) matrix of t-stats for
//   the variance-covariance matrix of the residuals
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
T=res('nobs')
nbparam=size(res('coeff'),1)
dll=T-nbparam
 
grocer_MS_typmod=res('typemod')
grocer_MS_K=res('nendo')
grocer_MS_M=res('nb_states')
grocer_MS_var_opt=res('var_opt')
grocer_MS_M_V=res('switching V')
if grocer_MS_M_V==1 then
   grocer_MS_MlikeMV=ones(1,grocer_MS_M)
else
   grocer_MS_MlikeMV=1
end
grocer_MS_sigma=res('sigma')
 
x_mat=res('xmat')
n_x=size(x_mat,2)
z_mat=res('zmat')
n_z=size(z_mat,2)
y_mat=res('ymat')
 
paramf=[]
if grocer_MS_var_opt == 3 then
   for j=1:grocer_MS_M_V
      paramf=[paramf ; vech(grocer_MS_sigma(:,(j-1)*grocer_MS_K+1:j*grocer_MS_K))]
 
   end
 
else //Diagonal covariance matrix Sigma(S(t)) //
 
   for j=1:grocer_MS_M_V
      paramf=[paramf ; diag(grocer_MS_sigma(:,(j-1)*grocer_MS_K+1:j*grocer_MS_K))]
   end
end
 
if n_x ~= 0 then
   paramf=[matrix(res('beta_id'),-1,1) ; paramf]
end
paramf=[matrix(res('ptrans')(1:$-1,:)',grocer_MS_M*(grocer_MS_M-1),1) ;paramf ]
if n_z ~= 0 then
   paramf=[paramf ; matrix(res('beta_co'),-1,1) ]
end
 
 
if res('meth') == 'ms mean' then
   grocer_MS_typmod=1
end
ptrans=res('ptrans')
 
grocer_Vec_Mat_foo=MSVAR_Vec_Matf
cont=%t
val=hdelta*[1;0.5;2;0.25;4;0.1;10;0.05;20;0.025;40;0.01;100]
i=1
while i < 12 & cont
   hout=hessian0(MSVAR_Filt,paramf,val(i));
   if det(hout)~=0 then
      covbeta=inv(hout);
      stderr=sqrt(diag(covbeta));
       if isreal(stderr) then
         cont=%f
      end
   else
      // =============handling inversion of matrix  to be improved ===========//
       write(%io(2),"Warning : Singular information matrix",'(a)')
      covbeta=pinv(hout,sqrt(%eps)); //=====Generalized sweep inversed matrix========//
      cont=%f
   end
   i=i+1
end
res('hes. delta')=val(i-1)
 
stderr=sqrt(diag(covbeta));
corbeta=var2cor(covbeta)
tstudent=paramf ./ stderr;
 
pvalue=ones(nbparam,1)
for i=1:nbparam
   pvalue(i)=(1-cdft("PQ",abs(tstudent(i)),dll))*2
end
res('stderr')=stderr
res('tstat')=tstudent
res('pvalue')=pvalue
res('covbeta')=covbeta
res('corbeta')=corbeta
 
i_start =grocer_MS_M*(grocer_MS_M-1);
i_end=i_start+n_x*grocer_MS_M;
C=pvalue(i_start+1:i_end);
beta_id_pvalue=matrix(C,n_x,grocer_MS_M);
 
 
res('beta_id_pvalue')=beta_id_pvalue
[sigma_pvalue] =MSVAR_Vec_Cov_tstat(pvalue,grocer_MS_K,grocer_MS_M,grocer_MS_var_opt,grocer_MS_M_V,grocer_MS_n_x);
res('sigma_pvalue')=sigma_pvalue
 
[ptrans_tstat,beta_id_tstat,beta_co_tstat,sigma_tstat]=...
MSVAR_Vec_tstat(tstudent,covbeta,ptrans,grocer_MS_K,grocer_MS_M,grocer_MS_var_opt,grocer_MS_M_V,grocer_MS_n_x,grocer_MS_n_z);
res('ptrans_tstat')=ptrans_tstat
res('beta_id_tstat')=beta_id_tstat
if res('meth') ~= 'ms mean' then
   KK=(grocer_MS_var_opt-1)*(3-grocer_MS_var_opt)+grocer_MS_K*(grocer_MS_var_opt-2)*((grocer_MS_var_opt-3)/2+(grocer_MS_K+1)*(grocer_MS_var_opt-1)/4)
   i_start =grocer_MS_M*(grocer_MS_M-1)+ n_x*grocer_MS_M + KK*grocer_MS_M_V;
   i_end=i_start+n_z;
   beta_co_pvalue=pvalue(i_start+1:i_end,:);
 
   res('beta_co_tstat')=beta_co_tstat
   res('beta_co_pvalue')=beta_co_pvalue
end
res('sigma_tstat')=sigma_tstat
 
ptrans_pvalue=ptrans
for i=1:size(ptrans,1)
   for j=1:size(ptrans,2)
	    ptrans_pvalue(i,j)=(1-cdft("PQ",abs(ptrans_tstat(i,j)),dll))*2
   end
end
res('ptrans_pvalue')=ptrans_pvalue
 
endfunction
