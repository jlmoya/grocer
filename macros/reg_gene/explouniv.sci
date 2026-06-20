function [grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_b,grocer_nonna]=explouniv(grocer_ly,grocer_lx,grocer_b,grocer_named,grocer_testna,grocer_dropna,grocer_mindat,grocer_lags)
 
// PURPOSE: explode endogenous and exogenous variables into
// matrices, names and define corresponding bounds
// ------------------------------------------------------------
// INPUT:
// * grocer_ly (grocer_lx) = list of variables:
//   each element could be
//   - a timeseries, a real vector,
//   a real matrix or a string (the name of a variable with
//   one of the types cited above, between quotes)
//   - a matrix of strings, each one being the name of a
//   variable
//   - the string 'cte' or 'const' if the user wants a constant
//     to be included automatically
// * grocer_b = a (px1) string vector (of dates) (optional:
//   if not given the function either takes the existing bounds
//   or determines the bounds suitable to the given series)
// * grocer_named = a (2x1) vector of strings representing thes
//   name of variable not entered between quotes
//   (optional; default = ['endogenous' ; 'exogenous'])
// * grocer_testna = a booelan indicating whether the program
//   will test the existence of na’s values in the matrices of
//   values grocer_y and grocer_x
// * grocer_dropna = a boolean indicating whether the program
//   should keep only lines of matrices grocer_y and grocer_x
//   with non na values in both matrices (suppose that
//   grocer_testna has been set to %f)
// ------------------------------------------------------------
// OUTPUT:
// * grocer_y = a (T x ky) real vector or a ts
// * grocer_namey = a (1 x ky) string vector
// * grocer_x = a (T x kx) real matrix
// * grocer_namexos = a (1 x kx) string vector
// * grocer_prests = a boolean indicating whether there is a ts
// * grocer_b = a (2 x 1) string matrix (of dates) or []
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2008
// http://grocer.toolbox.free.fr/grocer.html
 
[grocer_nargout,grocer_nargin] = argn(0)
 
if grocer_nargin < 3 then
   grocer_b=[ ]
end
if grocer_nargin < 4 then
   grocer_named=['endogenous' ; 'exogenous']
end
if grocer_nargin < 5 then
   grocer_testna=%t
end
if grocer_nargin < 6 then
   grocer_dropna=%f
end
if grocer_nargin < 7 then
   grocer_mindat=%f
end
if grocer_nargin < 8 then
   grocer_lags=zeros(2,1)
end
 
[grocer_mats,grocer_names,grocer_prests,grocer_b,grocer_nonna]=...
explon(list(grocer_ly,grocer_lx),grocer_named,grocer_b,grocer_testna,grocer_dropna,grocer_mindat,grocer_lags)
grocer_y=grocer_mats(1)
grocer_x=grocer_mats(2)
grocer_namey=grocer_names(1)
grocer_namexos=grocer_names(2)
 
endfunction
 
