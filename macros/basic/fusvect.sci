function [ind]=fusvect(varargin)
 
// PURPOSE: makes the fusion of (n x1) vectors and
// sort them in increasing order
// ------------------------------------------------------------
// INPUT:
// * (n x 1) vectors
// ------------------------------------------------------------
// OUTPUT:
// * ind = a (n x 1) vector
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
nargin=length(varargin)
ind=vec2col(varargin(1))
for i=2:nargin
   ind=[ind ; vec2col(varargin(i))]
end
ind=gsort(ind,'g','i')
 
endfunction
 
