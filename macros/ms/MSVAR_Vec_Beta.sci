function bet = MSVAR_Vec_Beta(param,K,M,n_x);
 
// PURPOSE: extract from the vector of parameters associated to
// the exogenous switching regressors variables in a MS-VAR
// model
// ------------------------------------------------------------
// INPUT:
// * param = a (np x 1) vector of parameters
// * K = # of endogenous variables
// * M = # of states
// * n_x = # of exogenous switching variables
// ------------------------------------------------------------
// OUTPUT:
// * bet = a (n_x*K*M x 1) vector of parameters
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
i_start =M*(M-1);
i_end=i_start+n_x*M;
C=param(i_start+1:i_end);
bet=matrix(C,n_x,M);
 
endfunction
