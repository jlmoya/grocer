function s=%tsmat_maxi(tsmat,loc)
 
// PURPOSE: define the maximum of a tsmat;
// the overloading capability of scilab allows then one to write
// max(tsmat) to take the max of time series tsmat
// The maximum can be computed in row, in column or and the
// whole table
// ------------------------------------------------------------
// INPUT:
// * tsmat= a tlist of type tsmat
// * loc =
//   . none the maximum is computed over the whole matrix
//   . 'r' the maximum is computed in row
//   . 'c' the maximum is computed in column
// ------------------------------------------------------------
// OUTPUT:
// * s = a real number or a ts
//    if the maximum is computed in column
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois & Emmanuel Michaux (2008)
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
[nargout,nargin]=argn(0);
if nargin < 2 then
   s = max(tsmat('series'))
elseif loc == 'r'
   s = max(tsmat('series'),loc)
elseif loc == 'c'
   s =tsmat;
   s('series') = max(tsmat('series'),'c')
   s('names')=null()
   s(1)=['ts';'freq';'dates';'series']
end
 
 
if or(tsmat,loc(1) == 'comments') then
   tsmat,loc('comments')=emptystr(size(tsmat,loc('names'),1),1)
end
 
endfunction
