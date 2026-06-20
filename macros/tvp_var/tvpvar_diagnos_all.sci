function [resA,resB,resQ,resW,resQ,resSigma]=tvpvar_diagnos_all(res,varargin)
 
// PURPOSE: computes MCMC convergence diagnostics for some
// type of results (At, Bt, S, Q, W or Htstd) from a tvp-var
// results
// ------------------------------------------------------------
// INPUT:
// * res = a tvp var results tlist
// * varargin = optional arguemnts that can be
//   - 'nautcorr=x' where x is the order of the aurocorrelation
//     tested for the draws
//   - 'npct_taper=x' where x is the % used to taper the window
//      in t for Geweke's test
//   - 'n_groups=x' where x is the the number of draws that are
//     aggregated before performing the correlations
//   - 'noprint' if the user does not want t print the results
// ------------------------------------------------------------
// OUTPUT:
// resA, resB, resQ, resW, resQ, resH:
// diagnostics results tlist for coefficents At, Bt, Q, W, Q and
// Hstd
// -----------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
 
resA=tvp_var_diagnos(res,'At',varargin(:))
resB=tvp_var_diagnos(res,'Bt',varargin(:))
resQ=tvp_var_diagnos(res,'Q',varargin(:))
resS=tvp_var_diagnos(res,'S',varargin(:))
resW=tvp_var_diagnos(res,'W',varargin(:))
resSigma=tvp_var_diagnos(res,'Sigmat',varargin(:))
 
endfunction
