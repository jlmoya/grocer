function rho_inv = MSVAR_Rho_inv(rho)
 
// PURPOSE: transforms a parameter constrainted to be between
// -1 and 1 into an unconstrainted parameter
// ------------------------------------------------------------
// INPUT:
// * rho_c = a (np x 1) vector of constrainted parameter
// ------------------------------------------------------------
// OUTPUT:
// * rho = a (np x 1) vector of unconstrainted parameter
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
 
rho_inv = tan((%pi/2)*rho)
 
 
 
 
endfunction
