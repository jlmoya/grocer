function [x,grocer_boundsvarb,grocer_prests,X,grocer_nonna]=eq2xcol(grocer_a,grocer_listeq,grocer_uneven,grocer_dropna)
 
// PURPOSE: transforms a list of strings into the column vector
// equal to the evaluation of the list of equations contained
// in grocer_listeq at point grocer_a
// ------------------------------------------------------------
// INPUT:
// * grocer_a = the vector of coefficients where the equations
//   must be evaluated
// * grocer_listeq = the list of equations in string form
// ------------------------------------------------------------
// OUTPUT:
// * x = the X matrix in the regression represented by the
// system of equations embedded in grocer_listeq
// * grocer_boundsvarb = the bounds of the regressions (if any)
// * grocer_prests = a boolean indicating whether there is a ts
// in the equations
// ------------------------------------------------------------
// NOTES:
// * the coefficients must be named grocer_a(i) in the
// equations
// * this function is used in sur to evaluate the first
// derivative of the equations with respect to the coefficients
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2006
// http://grocer.toolbox.free.fr/grocer.html
 
[X,grocer_namexos,grocer_prests,grocer_boundsvarb,grocer_nonna]=...
   explone(grocer_listeq,[],'exog',~grocer_uneven,grocer_dropna)
 
x=X(:)
x=x(~isnan(x))
 
endfunction
