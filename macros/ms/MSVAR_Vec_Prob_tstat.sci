function [PR_TR_tstat,PR_TR_stderr] = MSVAR_Vec_Prob_tstat(varcov,M)
 
// PURPOSE: recoverss the standard errors associated to the
// transition probabilities in a MSvar estimation
// ------------------------------------------------------------
// INPUT:
// * varcov = a (np x np) var-cov matrix
// * M = # of states
// ------------------------------------------------------------
// OUTPUT:
// * PR_TR_tstat = the (M x M) t-stat matrix of the transition
//   probabilities
// * PR_TR_stderr = the (M x M) standard error matrix of the
//   transition probabilities
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
A=varcov(1:M*(M-1),1:M*(M-1))
// recovers the variances that have been already calculated
B=matrix(sqrt(diag(A)),M,M-1)'
 
aux=zeros(1,M)
// recovers the variances of the probabilities that are calculated
// as 1-sum of probabilities in the column
for i=1:M
   aux(i)=sqrt(sum(varcov(i+[0:M-2]*M,i+[0:M-2]*M)))
end
 
PR_TR_stderr=[B ; aux]
PR_TR_tstat=PR_TR ./ PR_TR_stderr
endfunction
