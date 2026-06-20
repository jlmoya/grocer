function car=joinstr(varargin)
 
// PURPOSE: (similar to the one with the same name in portable
// troll) concatenate elements which can be strings or
// matrix of strings; when some arguments are vectors of string,
// then the function creates a string for each element of the
// vector by concatening it with the arguments of size 1 (the
// last one notwithstanding), in the order they are given by
// the user; then the function concatenates these strings with
// the last element as a separator
// ------------------------------------------------------------
// INPUT:
// * objects which can be strings or column vectors of strings;
//   each vector must then have the same size
// ------------------------------------------------------------
// OUTPUT:
// * car = a string
// ------------------------------------------------------------
// NOTES:
// * very useful, but for experts
// * used by prevstat()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
nargin=length(varargin)
if nargin <2 then
   error('not enough arguments in function joinstr')
end
 
sep=varargin(nargin)
 
sizearg=ones(nargin-1,1)
for i=1:nargin-1
   sizemin=min(size(varargin(i)))
   if sizemin ~= 1 then
      error('arg # '+string(i)+' is not a scalar or a vector')
   end
   sizearg(i)=max(size(varargin(i)))
end
nlabels=max(sizearg)
 
testnvar=and([sizearg ~= 1 sizearg ~= nlabels])
if testnvar then
   error('labels in joinstr have not the same number of columns')
end
 
car=emptystr()
for i=1:nargin-1
   car=car+varargin(i)(1)
end
for j=2:nlabels
   car=car+sep
   for i=1:nargin-1
      indvar=min(j,sizearg(i))
      car=car+varargin(i)(indvar)
   end
end
 
endfunction
 
