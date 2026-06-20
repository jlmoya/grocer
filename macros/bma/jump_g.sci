function [vin,vout] = jump_g(vin,vout,nvmax)
 
// PURPOSE: function used by sar BMA models to sample variables for changing model size
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
// REFERENCE:
// Peter J. Green, "Reversible Jump Markov Chain Monte Carlo
// Computation & Bayesian Model Determination",
//	Biiometrika, Vol. 8, No. 4, pp. 711-732
// ----------------------------------------------------------
//
// Translated and improved by E. Dubois and E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
// written by:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
// last modified June, 2004
 
// find size of variables in/out of the model
nv1 = length(vout)
nv2 = length(vin)
 
 
// decide on increase, move, decrease model size
moves = grand(1,1,'bin',1,1/3)
if moves then
	choose0 = floor(grand(1,1,'unf',1,nv2+1))
	choose1 = floor(grand(1,1,'unf',1,nv1+1))
 
	junkout = vout
	
	vout(choose1) = []
	vout = [vout vin(choose0)]
 
	vin(choose0) = []		
	vin = [vin junkout(choose1)]
else
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
end 	
 
 
endfunction
