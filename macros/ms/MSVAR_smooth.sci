function PR_smoothed = MSVAR_smooth(PR_STT,PR_STL,PR_TR);
 
// PURPOSE: computes the smoothed probabilities in a MS
// estimation
// ------------------------------------------------------------
// INPUT:
// * PR_STT = a (T x M) matrix of filtered probabilities of
//   each state at each date
// * PR_STL = a (T x M) matrix of filtered probabilities of
//   each state at each date, condtionned by the date t-1
// ------------------------------------------------------------
// OUTPUT:
// * PR_smoothed ) = a (T x M) matrix of smoothed probabilities
//   of each state at each date
// ------------------------------------------------------------
// REFERENCES:
// * Benoit BELLONE: "Classical Estimation of Multivariate
//  Markov-Switching Models using MSVARlib", (2005).
// available at http://bellone.ensae.net
// e-mail: benoit.bellone@ensae.org
// * Adapated courtesy of Hamilton (1989), Hamilton (1994) 			
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
T=size(PR_STT,1);
PR_smoothed=PR_STT;
 
for temps =T-1:-1:1
 
    PR_smoothed(temps,:)= (matmul(PR_STT(temps,:)',PR_TR'*(PR_smoothed(temps+1,:)' ./ PR_STL(temps+1,:)')))';
 
end
endfunction
