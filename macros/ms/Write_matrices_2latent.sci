function [PZ,PX_c,PZ_ti,PW]=Write_matrices_2latent(vect,nbstates);
 
// PURPOSE: calculate the log-likelihood of a Hidden-Markov-
// Model for the detection of truning points in qualitative
// variables
// ------------------------------------------------------------
// INPUT:
// * vect = a (Np X 1) vector of parmaeters
// * nbstates = the # of latent states
// ------------------------------------------------------------
// OUTPUT:
// * PZ = a (nbstates x nbstates) matrix of transition
//   probabilities
// * PX_c = a ((nvar.nbquat) x nbstates) matrix of conditional
//   probabilities (probabilities that the observed variables
//   take each of the possible values for each state)
// * PZ_ti = a (2 x 2) matrix of transition probabilities for
//   the first latent state
// * PW = a (2 x 2) matrix of transition probabilities for
//   the first latent state
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated and adapted from a Gauss programm by J. Bardaji
// and F. Tallet
 
PZ_ti=zeros(2,2);
PW=zeros(2,2);
PX_c=ones(nvar*nbqua(1),nbstates)/nbqua(1);
 
transvect=exp(vect) ./ (1+exp(vect))
// Matrix PZ_t //
PZ_ti(1,1:2)=transvect(1:2)'
PZ_ti(2,1:2)=1-PZ_ti(1,1:2);
 
PW(1,1:2)=transvect(3:4)'
PW(2,1:2)=1-PW(1,1:2);
 
PZ=PZ_ti .*. PW;
PZ=PZ(1:nbstates,1:nbstates);
 
// Matrix PX_c //
PX_c(2*[1:nvar]-1,1)=transvect(4+[1:nvar])
PX_c(2*[1:nvar]-1,3)=transvect(4+nvar+[1:nvar])
PX_c(2*[1:nvar],[1 3])=1-PX_c(2*[1:nvar]-1,[1 3])
 
endfunction
 
