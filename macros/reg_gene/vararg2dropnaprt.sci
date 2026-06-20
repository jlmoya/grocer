function [dropna,prt,varargin]=vararg2dropnaprt(varargin)
 
// PURPOSE: return from the options of an econometric function
// whose options can only be 'noprint' or dropna' the values of
// the booleans dropna and prt that indicate whether to drop
// na from a ts and to print results
// ------------------------------------------------------------
// INPUT:
// * varargin = a variable number of arguments that can take
//   the values 'dropna' or 'noprint'
// ------------------------------------------------------------
// OUTPUT:
// * dropna = a boolean indicating whether to drop na from a ts
// * prt = a boolean indicating whether to print results
// * varargin = the list of the arguments other than 'dropna'
//   and 'noprint'
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
dropna=%f
prt=%t
nargin=length(varargin)
for i=nargin:-1:1
   argi=varargin(i)
   if typeof(argi) == 'string' then
      argi=strsubst(argi,' ','')
      if argi == 'noprint' then
         prt=%f
         varargin(i)=null()
      elseif argi == 'dropna' then
         dropna=%t
         varargin(i)=null()
      end
   end
end
 
endfunction
