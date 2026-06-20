function PR_TR = MSVAR_Vec_Prob(param,M);
 
// PURPOSE: extract the transition probabilities from the
// vector of parameters
// ------------------------------------------------------------
// INPUT:
// * param = a (np x 1) vector of aprameters
// * M = # of states
// ------------------------------------------------------------
// OUTPUT:
// * PR_TR = the (M x M) matrix of transition probabilities
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
 
A=param(1:M*(M-1),1)
Aux_p=matrix(A,M,M-1)'; // reshape_gauss is equivalent to matrix()' when the
                    // start and destination matrices have the same number of arg
B=min(real(exp(Aux_p)),1E6);
Sum=ones(1,M)+sum(B,1); // sumc(B)'
aux_p=B ./ (ones(M-1,1) .*. Sum)
 
PR_TR=[aux_p ; (ones(1,M)-sum(aux_p,'r'))]
 
 
endfunction
