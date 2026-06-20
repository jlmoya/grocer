function res=prandom4auto_upd(res,y,namexos,indx,val,p,ncomp,list_vararg)
 
// PURPOSE: supplement basic ols results stored in the input
// tlist (implicitely resulting from function ols2auto_part)
// ------------------------------------------------------------
// INPUT:
// * res = a results tlist, containing basic ols results
// * y = a (nobs x 1) vector of endogenous variables
// * namexos = a (k+l) vector of strings, the name of all
//   exogenous variables
// * r0 = a predefined tlist result whose needed fileds
//   already exist
// * indexos = the index of the x variables in the regression
// * val = a vector, the values of the specification tests
// * p = the corresponding p-values
// * varargin = an empty list of arguments (added to the input
//   of the function by confirmity with other functions that
//   can be called by the package automatic)
// ------------------------------------------------------------
// OUTPUT:
// * res = the results tlist, with full results
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012-2013
// http://grocer.toolbox.free.fr/grocer.html
 
 
res('namex')=['const' ; namexos(indx) ; res('name individual')]
 
endfunction
