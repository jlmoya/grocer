function vecout=polymult(vec1,vec2)
 
// PURPOSE: function that mimics gauss function polymult
//  polymult = Scilab function convol ! (but with greater precision)
// ------------------------------------------------------------
// INPUT:
// * vec1 = a (nx1) vector of coefficients representing a
//   polynom
// * vec2 = a (mx1) vector of coefficients representing a
//   polynom
// ------------------------------------------------------------
// OUPTUT:
// * vecout = a ((n+m)x1) vector of coefficients representing a
//   polynom
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
vecout=coeff(poly(vec2col(vec1),'x','coef')*poly(vec2col(vec2),'x','coef'))
 
endfunction
 
