function MSVAR_PrintMoment(y_mat,M,M_V,init_beta_id,init_beta_co,init_var);
 
// PURPOSE: prints  basic statistical moments of a matrix,
// bound to initialize a Mean-Variance MS-model
// ------------------------------------------------------------
// INPUT:
// * y_mat = a (T x N) matrix of variables
// * M = # of states
// ------------------------------------------------------------
// OUTPUT:
// * Sig_mat = the variance matrix of the residuals
// * inv_Sig_mat = the inverse of variance matrix
// * det_inv_Sig_mat = the determinant of the inverse of
//   variance matrix
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
 
[mu_out,cov1,cov3]= MSVAR_InitMoment(y_mat,grocer_MS_apriori,M,M_V,init_beta_id,init_beta_co,init_var);
 
write(%io(2),"mu_out:",'(a)');
disp(mu_out)
write(%io(2)," ",'(a)');
 
if M == M_V then
   write(%io(2),"variance-covariance (Regime in columns, vectorized covariance matrix):",'(a)');
   disp(cov1)
   write(%io(2)," ",'(a)');
   write(%io(2),"variance-covariance (Regime in columns, vectorized covariance matrix):",'(a)');
   disp(cov3)
   write(%io(2)," ",'(a)');
 
else
   write(%io(2),"cov1:",'(a)');
   disp(cov1)
   write(%io(2)," ",'(a)');
   write(%io(2),"cov3:",'(a)');
   disp(cov3)
   write(%io(2)," ",'(a)');
 
end
 
endfunction
