function delta = MSVAR_Vec_Delta(param,K,M,v_opt,M_V,n_x,n_z);
 
// PURPOSE: converts a vector of parameters delta (exogenous
// non- switching regressors) in a matrix delta (n_z,K)
// ------------------------------------------------------------
// INPUT:
// * param = a (np x 1) vector of parameters
// * K = # of endogenous variables
// * M = # of states
// * v_opt = the option for the type of variance matrix
//   v_opt =1 ==> heteroscedastic version
//   v_opt =2 ==> Homoscedastic version
//   v_opt =3 ==> Full covariance matrix
// * M_V = 1 if there is no switching parameter, M if there are
//   switching parameters
// * n_x = # of exogenous switching variables
// * n_z = # of exogenous non switching variables
// ------------------------------------------------------------
// OUTPUT:
// * delta = a (n_z x K) matrix of parameters
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
 
i_start =M*(M-1)+ n_x*M + KK*M_V;
i_end=i_start+n_z;
delta=param(i_start+1:i_end,:);
 
endfunction
