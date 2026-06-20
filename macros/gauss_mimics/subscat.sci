function y = subscat(x,v,s)
 
// PURPOSE: mimic gauss function subscat: Parses a string,
// returning a character vector of tokens
// ------------------------------------------------------------
// INPUT:
// * x = (N x 1) string array
// * v = (P x 1) numeric vector, containing breakpoints
//   specifying the ranges within which substitution is to be
//   made. This MUST be sorted in ascending order
// * x = (P x 1) vector, containing values to be substituted
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x 1) string array vector, with the elements in s
//   substituted for the original elements of x according to
//   which of the regions the elements of x fall into:
//   x <= v(1)             --> s(1)
//   v(1) < x <= v(2),     --> s(2)
//        .
//        .
//        .
//   v(p - 1) < x <= v(p)  --> s(p)
//   v(p) < x              --> original x value
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
P=size(v,1)
y=x
y(x <= v(1))=s(1)
for i=2:P
   y(x > v(i-1) & x <= v(i))=s(i)
end
 
endfunction
