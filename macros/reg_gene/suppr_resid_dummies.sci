function [resid,nb_suppr_resid]=suppr_resid_dummies(resid,exo,max_nonzeros)
 
// PURPOSE: withdraw from a vector residuals the one
// corresponding to dummies in the set of exogenous variables
// (useful for drawings in a bootstrap context)
// ------------------------------------------------------------
// INPUT:
// * resid = a (n x 1) vector of residuals
// * exo = a (n x k) matrix of exogenous variables
// * max_nonzeros = a scalar, the maximum # of non zeros values
// ------------------------------------------------------------
// OUTPUT:
// * resid= the residuals not corresponding to dummies
// * nb_suppr_resid = the # of withdrawn residuals
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
suppr_resid=[]
for i=1:size(exo,2)
// calculate the number of non 0 terms in the column i
   nb_nonzeros=find(exo(:,i)~=0)
// if the # of 0 is lower than the threshold, then the column is
// considered as representing a dummy and the observations
// corresponding to the dummy must be withdrawn
   if size(nb_nonzeros,2) <= max_nonzeros then
      suppr_resid=fusvect(suppr_resid,nb_nonzeros)
   end
end
nb_suppr_resid=size(suppr_resid,'*')
resid(suppr_resid,:)=[]
 
endfunction
