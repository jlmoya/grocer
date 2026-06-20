function []=add_derivative(func,deriv)
 
// PURPOSE: add a derivative to the list of analytic ones
// ------------------------------------------------------------
// INPUT:
// * func = a string vector, containing the names of the
//   added functions
// * deriv = a string vector, containing the names of the
//   corresponding derivative
// ------------------------------------------------------------
// OUTPUT:
// nothing: names are added to the objects grocer_listfunctions
// and grocer_listderivatives in database:
// GROCERDIR+'param\symb_listfunc.dat'
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012-2013
// http://grocer.toolbox.free.fr/grocer.html
 
load(GROCERDIR+'param\symb_listfunc.dat')
 
if typeof(func) ~= 'string' then
   error('arg 1 should be of string type')
end
if typeof(deriv) ~= 'string' then
   error('arg 1 should be of string type')
end
 
if min(size(func)) > 1 then
   error('arg 1 should be a row or column vector')
end
if min(size(deriv)) > 1 then
   error('arg 1 should be a row or column vector')
end
if size(func,'*') ~= size(deriv,'*') then
   error('the number of derivatives is diffent from the number of primitives')
end
grocer_listfunctions=[ func(:) ; grocer_listfunctions]
grocer_listderivatives=[deriv(:) ; grocer_listderivatives]
 
if getversion("scilab")(1) >= 5.4 then
   save(GROCERDIR+'param\symb_listfunc.dat','grocer_listfunctions','grocer_listderivatives')
else
   save(GROCERDIR+'param\symb_listfunc.dat',grocer_listfunctions,grocer_listderivatives)
end
 
endfunction
