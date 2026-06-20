function [PZ,PX_c]=Write_matrices_1latent0(vect,nbstates,nojump);
 
// PURPOSE: calculate the log-likelihood of a Hidden-Markov-
// Model for the detection of truning points in qualitative
// variables
// ------------------------------------------------------------
// INPUT:
// * vect = a (Np X 1) vector of parmaeters
// * nbstates = the # of latent states
// * nojump = a boolean indicating whether the state cannot
//   jump to a disjoined state
// ------------------------------------------------------------
// OUTPUT:
// * PZ = a (nbstates x nbstates) matrix of transition
//   probabilities
// * PX_c = a ((nvar.nbquat) x nbstates) matrix of conditional
//   probabilities (probabilities that the observed variables
//   take each of the possible values for each state)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated and adapted from a Gauss programm by J. Bardaji
// and F. Tallet
 
PX_c=zeros(nvar*nbqua(1),nbstates);
 
// Matrix PZ
if nojump then
 
   PZ=diag(vect(1:nbstates))
   PZ(2,1)=1-PZ(1,1)
   for i=2:nbstates-1
      PZ(i-1,i)=vect(nbstates+i-2)
      PZ(i+1,i)=1-PZ(i,i)-PZ(i-1,i)
   end
   indvect=2*nbstates-2
   PZ(nbstates-1,nbstates)=vect(indvect)
   PZ(nbstates,nbstates)=1-PZ(nbstates-1,nbstates)
 
else
 
   PZ=zeros(nbstates,nbstates);
   PZ(1:nbstates-1,1:nbstates)=matrix(vect(1:nbstates*(nbstates-1)),nbstates-1,nbstates)
   indvect=nbstates*(nbstates-1)
 
end
PZ(nbstates,1:nbstates)=1-sum(PZ(1:nbstates-1,:),'r');
//PZ=(PZ+eps)/(1+nbstates*eps)
 
vect=matrix(vect(indvect+1:$),nvar*(nbqua(1)-1),nbstates)
indvect=[1:(nbqua(1)-1)]
 
for i=1:nvar
   PX_c(nbqua(1)*(i-1)+[1:nbqua(1)-1],:)=vect(indvect,:)
   PX_c(nbqua(1)*i,:)=1-sum(PX_c(nbqua(1)*(i-1)+[1:nbqua(1)-1],:),'r')
   indvect=indvect+nbqua(1)-1
end
//PX_c=(PX_c+eps)/(1+nbqua(1)*eps)
 
endfunction
 
