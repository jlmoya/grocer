function s=%tsmat_sum(tsmat,loc)
 
// PURPOSE: define the sum a matrix of time series;
// the overloading capability of scilab allows then one to write
// sum(tsmat) to take the max of time series tsmat
// The sum can be computed in row, in column or and the
// whole table
// ------------------------------------------------------------
// INPUT:
// * ts= a time series
// * loc =
//   . none the maximum is computed over the whole matrix
//   . 'r' the maximum is computed in row
//   . 'c' the maximum is computed in column
// ------------------------------------------------------------
// OUTPUT:
// * s = a real number or a ts if the sum is computed
//      in column
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois & Emmanuel Michaux (2008)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0);
if nargin < 2 then
  s = sum(tsmat('series'))
elseif (loc == 'r') | (loc==1) then
  s = sum(tsmat('series'),loc)
elseif (loc == 'c' ) | (loc==2) then
  s =tsmat;
  s('series') = sum(tsmat('series'),'c')
  s('names')=null()
  s(1)=['ts';'freq';'dates';'series']
end
 
 
if or(tsmat,loc(1) == 'comments') then
   tsmat,loc('comments')=emptystr(size(tsmat,loc('names'),1),1)
end
 
endfunction
