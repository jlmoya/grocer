function PR_ergodic=MSVAR_Ergodic(ptrans_init,M)
 
// PURPOSE: computes equilibrium stationary ergodic
// probabilities P(M,1) - See Hamilton(1994), chap 22
// ------------------------------------------------------------
// INPUT:
// * ptrans_init = a (M x M) matrix of transition probabilities
// * M = size of ptans_init
// ------------------------------------------------------------
// OUTPUT:
// * PR_ergodic = the (M x 1) vector of ergodic probabilities
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
A = [(eye(M,M)-ptrans_init) ; ones(1,M)]
EN=[zeros(M,1);1]
PR_ergodic = pinv(A'*A)*A'*EN
endfunction
