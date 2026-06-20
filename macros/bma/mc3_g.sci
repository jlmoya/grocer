function [vin,vout] = mc3_g(vin,vout,nvmax)
	
// PURPOSE: function used by bma_g2 to sample variables for
// changing model size (called by bma_g)
// ----------------------------------------------------------
// INPUT:
// * vin  = a 1 x nvar1 vector of variable #'s for
//   variables included in the model
// * vout = a 1 x nvar2 vector of variable #'s for
//   variables excluded from the model
// * nvmax = max # of variable allowed in each model
// ----------------------------------------------------------
// RETURNS:
// * vin = a 1 x nvar1+1 or 1 x nvar1-1 vector of
//   variable #'s in the new model
// * vout = a 1 x nvar2+1 or 1 x nvar2-1 vector of
//   variable #'s excluded from the new model
// ----------------------------------------------------------
// written by:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
//
// Translated and improved by E. Dubois and E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
 
 
nv1 = length(vout)
nv2 = length(vin)
 
// decide on increase-decrease model size
 
// in the general case there will be both included and excluded
// variables; therefore nv1*(nvar-nv2) will be non zero
// and the program will execute only one test to create the
// variable increase: this is the best that can be obtained!
 
if (nv2-nvmax)*(nv2-1) then
   increase=floor(2*grand(1,1,'def'))
else
// either nv1=0 or nv2=1; in the first case, you must increase
// and in the second one decrease
   increase=(nv2==1)
end
 
if increase then // increase model size
   choose = floor(grand(1,1,'unf',1,nv1+1))
   vin = [vin vout(choose)]
   vout(choose) = []
else // decrease model size
   choose = floor(grand(1,1,'unf',1,nv2+1))
   vout = [vout vin(choose)]
   vin(choose) = []
end
 
endfunction
