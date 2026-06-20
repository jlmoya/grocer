function m=str2mat(varargin)
 
// PURPOSE: function that mimics matlab function str2mat: forms
// the string matrix
// ------------------------------------------------------------
// INPUT:
// * varargin = a variable number of strings
// ------------------------------------------------------------
// OUPTUT:
// * m = a (px1) vector of strings
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
nargin=length(varargin)
if nargin ==0 then
   m=emptystr()
else
   m=vec2col(varargin(1))
   for i=2:nargin
      if typeof(varargin(i)) ~= 'string' then
         error('arguments in str2mat should be strings')
      else
         maux=vec2col(varargin(i))
         [nr,nc]=size(maux)
         if nc ~=1 then
            error('str2mat accepts only vectors as entries')
         else
            m=[m ; maux]
         end
      end
   end
end
 
endfunction
 
