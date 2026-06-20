function gmmDiagW(W,iter)
 
// PURPOSE: : Plots GMM weighting matrix
//-------------------------------------------------------------------------
// INPUTS:
//  . W    = matrix to print
//  . iter = indicates iteration number
//-------------------------------------------------------------------------
// OUPUTS:   nothing
//-------------------------------------------------------------------------
// WRITTEN BY:	Mike Cliff,  Purdue Finance,  mcliff@mgmt.purdue.edu
// DATE:		11/6/99
// E. Michaux (2006) for the scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)  ;
msg = 'GMM weighting matrix';
if nargin == 2 then
  msg = msg+' at iteration '+string(iter);
end
 
ng=winsid() ; 		// get list of open graph windows
ng = ng($)+1 ;  // create a new window
 
hf = scf(ng);
ha = hf.children;
hist3d(W);			// Make plot
ha.rotation_angles = [5,130];
endfunction
 
 
 
 
