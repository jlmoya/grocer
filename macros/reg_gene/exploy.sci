function [grocer_y,grocer_namey,grocer_prests,grocer_b]=exploy(grocer_namey,grocer_b)
 
// PURPOSE: from a variable grocer_namey, store the values of
// the corresponding series in a vector, and, if necessary,
// define the admissible estimation bounds
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a variable which can be a timeseries, a
//   real vector or a string (the name of a variable with
//   one of the types cited above, between quotes),
// * grocer_b = a (px1) string vector (of dates) (optional:
//   if not given the function either takes the existing bounds
//   or determines the bounds suitable to the given series)
// ------------------------------------------------------------
// OUPTUT:
// * grocer_y = a (Tx1) real vector or a ts
// * grocer_namey = a string
// * grocer_prests = a boolean indicating if y is or is not a
//   ts
// * grocer_b = a (px1) string vector (of dates)
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// ols(), olsc(), automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_prests=%f
 
[grocer_nargout,grocer_nargin] = argn(0)
if grocer_nargin < 1 then
   error('nargin should be > 0')
 
elseif grocer_nargin == 1 then
   if exists('grocer_boundsvar') then
      grocer_b=grocer_boundsvar
   else
      grocer_b=[]
   end
end
 
 
// define the name of the variable y and the vector of values
if typeof(grocer_namey) == 'string' then
   grocer_y=evstr(grocer_namey)
else
   grocer_y=grocer_namey
   grocer_namey='endogenous'
end
 
 
select typeof(grocer_y)
 
case 'ts' then
   grocer_prests=%t
   if grocer_b == [] then
      grocer_d=datets(grocer_y)
      indnonna=find(~isnan(grocer_y('series')))
      if indnonna == [] then
         error('input series has only NA values')
      end
      firstnonna=indnonna(1)
      delnonna=indnonna-[firstnonna:firstnonna-1+size(indnonna,2)]
      consnonna=find(delnonna==0)
      lastnonna=consnonna(size(consnonna,2))+firstnonna-1
      grocer_fq=freqts(grocer_y)
      grocer_b=num2date([grocer_d(firstnonna);grocer_d(lastnonna)],grocer_fq)
   end
 
case 'constant' then
   nc=size(grocer_y,2)
   if nc ~= 1 then
      error(grocer_namey+' should be a column vector')
   end
 
else
   error('not an admissible type for '+grocer_namey)
end
 
endfunction
 
