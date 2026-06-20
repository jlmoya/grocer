function array=%array_e(varargin)
 
// PURPOSE: overload th extraction for (Gauss) arrays
// ------------------------------------------------------------
// INPUT:
// * vavargin = # of rows, # of cols, array
// ------------------------------------------------------------
// OUTPUT:
// * the extraction from the array, collapsed to a matrix of
//   type 'constant' if the extracted contains only numbers, to
//   type 'string' if the extracted contains only strings
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
 
nargin=length(varargin)
array=varargin(nargin)
varargin($)=null()
val=array('value')
txt=array('text')
newtxt=txt(varargin(:))
newval=val(varargin(:))
 
if and(isnan(newval)) then
   array=newtxt
elseif and(~isnan(newval)) then
   array=newval
else
   array('text')=newtxt
   array('value')=newval
end
 
endfunction
