function m=%tsmat_mean(tsmat,varargin)
 
// PURPOSE: define the mean of a time series;
// the overloading capability of scilab allows then one to write
// mean(ts) to take the mean of time series ts
// ------------------------------------------------------------
// INPUT:
// * tsmat = a matrix of time series
// ------------------------------------------------------------
// OUTPUT:
// * m =
// ------------------------------------------------------------
// Copyright: Eric Dubois 2016
// http://grocer.toolbox.free.fr/grocer.html
 
x=tsmat('series')
if isempty(varargin) then
   m =mean0(x)
 
elseif varargin(1) == 'r' | varargin(1) == 1 then
   m=mean0(x,'r')
 
elseif varargin(1) == 'c' | varargin(1) == 2 then
   m=tlist(['ts';'freq';'dates';'series'],tsmat('freq'),tsmat('dates'),mean0(x,2))
 
end
 
 
if or(tsmat(1) == 'comments') then
   tsmat('comments')=emptystr(size(tsmat,varargin('names'),1),1)
end
 
endfunction
