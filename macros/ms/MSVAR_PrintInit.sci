function MSVAR_PrintInit(param,K,M,var_opt,M_V,n_x,n_z);
 
//==========================================================================================================================
// MSVARlib Version 2.0 - January 2005   							    																
// First Version  - May 2004   							    																	    			
// Benoit BELLONE                                         							   	   							
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved - http://bellone.ensae.net - e-mail: benoit.bellone@ensae.org
// To install and adapt this program : MSVARlib_readme.txt             						
//  See for more detail : "Classical Estimation of Multivariate Markov-Switching Models using MSVARlib", (2005).	
//
//==========================================================================================================================
 
 
//==============================================PrintInit=======================================================================
// MSVAR_printinit
//  prints  a reconstructed set of parameters, bound to initialize the estimation
//==========================================================================================================================
 
 
param_init=MSVAR_Constraint(param);
[PR_ergodic_init,ptrans_init,beta_init,delta_init,var_cov_init,inv_var_cov_init,det_inv_var_cov_init]...
=MSVAR_Vec_Mat(param,K,M,var_opt,M_V,n_x,n_z);
 
write(%io(2),"=================Initial real and transformed parameters, para_m and param_init:==================",'(a)');
disp([param param_init]);
 
write(%io(2)," ",'(a)')
write(%io(2),"# of parameters",'(a)');
disp(size(param,1));
write(%io(2)," ",'(a)');
 
 
write(%io(2),"==================Initial matrix of transition markovian probabilities, ptrans_init:==================",'(a)');
disp(ptrans_init);
write(%io(2)," ",'(a)');
 
write(%io(2),"==================Initial switching regressors (or intercepts), Beta :==================",'(a)');
disp(beta_init);
write(%io(2)," ",'(a)');
 
write(%io(2),"==================Initial ergodic state probabilities, prob_st_init:==================",'(a)');
disp(PR_ergodic_init);
write(%io(2)," ",'(a)');
 
write(%io(2),"==================Initial state covariance, var_init:=========================",'(a)');
disp(var_cov_init');
write(%io(2)," ",'(a)');
 
write(%io(2),"=========================Det(inv(var_cov_init)):=========================",'(a)');
disp(det_inv_var_cov_init);
write(%io(2)," ",'(a)');
 
write(%io(2),"==================Initial non switching regressors (or intercepts), Delta :==================",'(a)');
disp(delta_init(:,1));
 
 
 
 
endfunction
