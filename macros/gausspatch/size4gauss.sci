function varargout = size4gauss(x,varargin)
 
// PURPOSE:
// ------------------------------------------------------------
// INPUT:
// * x = a (N x 1) vector of numeric data
// ------------------------------------------------------------
// OUTPUT:
// * ind = (N x 1) vector representing sorted index of x.
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
if typeof(x) == 'array' then
   x=x('value')
end
varargout=size(x,varargin(:))
 
endfunction
 
