function rho_c = MSVAR_Rho_constraint(rho)
 
// PURPOSE: transforms an unconstrainted parameter into a
// parameter constrainted to be between -1 and 1
// ------------------------------------------------------------
// INPUT:
// * rho = a (np x 1) vector of unconstrainted parameter
// ------------------------------------------------------------
// OUTPUT:
// * rho_c = a (np x 1) vector of constrainted parameter
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
 
rho_c = (2/%pi)*atan(rho);
 
 
 
endfunction
