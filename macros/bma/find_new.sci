function [j,visits] = find_new(binsave,vinew,visits,nvar,convert)
 
// PURPOSE: determines if the variables in vinew
// represent a new model (called by bma_g2)
//-------------------------------------------------------
// INPUT:
// * vsave = (i x nvar) matrix of indicators for models
// * vinew = (1 x k1) vector with current model
//   indicators
// * visits = matrix for recording # of visits
//   to a model
//-------------------------------------------------------
// RETURNS:
// * j = index to an old model found or i if the model is
//       new
// * visits = matrix recording visits to old models
//-------------------------------------------------------
// Copyright: E. Dubois and E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
// Translated and improved from a matlab program by:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
vitmp = zeros(1,nvar)
vitmp(vinew) = 1
vitmp = vitmp*convert
 
j = find(binsave == vitmp)
if size(j,1) ~=0 then
	visits(j) = visits(j)+1
else
	j = size(binsave,1)+1
	visits = [visits;1]
end
endfunction
