function [grocer_y,grocer_namey,grocer_prests,grocer_b]=explol(grocer_ly,grocer_b,grocer_named,grocer_tetsna,grocer_nobs)
 
// PURPOSE: from a list of variables, store the values of
// the corresponding series in a amtrix, their names in a
// vector and, if necessary, define the admissible estimation
// bounds
// ------------------------------------------------------------
// INPUT:
// * grocer_ly = list of variables:
//   each element could be
//   - a timeseries, a real vector,
//   a real matrix or a string (the name of a variable with
//   one of the types cited above, between quotes)
//   - a matrix of strings, each one being the name of a
//   variable
//   - the string 'cte' or 'const' if the user wants a constant
//     to be included automatically
// * grocer_b = a (px1) string vector (of dates) (optional:
//   if not given the function either takes the existing bounds
//   or determines the bounds suitable to the given series)
// * grocer_named = a string representing the name of variables
//   not entered between quotes
//   (optional; default = 'endogenous')
// * grocer_testna = a booelan indicating whether the program
//   will test the existence of na’s values in the matrix y
// ------------------------------------------------------------
// OUPTUT:
// * grocer_y = a (Txk) real matrix
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
 
[grocer_nargout,grocer_nargin] = argn(0)
if grocer_nargin < 4 then
   grocer_testna=%t
end
 
if grocer_nargin < 3 then
   grocer_named='endogenous'
end
 
if exists('grocer_boundsvar') & grocer_boundsvar ~= [] then
   if ~exists('grocer_b','local') then
      grocer_b=grocer_boundsvar
   elseif grocer_b == [] then
      grocer_b=grocer_boundsvar
   end
end
 
[grocer_namey,grocer_listtsy,grocer_vecy,grocer_indtsy,grocer_indvecy,grocer_indctey,grocer_ny]=...
explovars(grocer_ly,grocer_named)
 
grocer_prests=(length(grocer_listtsy) ~= 0)
 
if grocer_prests then
 
   ntsy=size(grocer_indtsy,1)
 
   if exists('grocer_b','local') then
      if grocer_b == [] then
         [grocer_yts,grocer_b]=explots(grocer_listtsy,%f)
         [nobs,nvar]=size(grocer_yts)
      else
         if grocer_listtsy ~= [] then
            grocer_yts=[]
            for grocer_i=1:size(grocer_indtsy,1)
               grocer_yts=[grocer_yts ts2vec(grocer_listtsy(grocer_i),grocer_b)]
            end
         end
      end
 
      nobs=size(grocer_yts,1)
 
   else
 
      [grocer_yts,grocer_b]=explots(grocer_listtsy,%t)
      [nobs,nvar]=size(grocer_yts)
 
   end
 
   grocer_y=ones(nobs,grocer_ny)
   grocer_y(:,grocer_indtsy)=grocer_yts
   grocer_y(:,grocer_indvecy)=grocer_vecy
 
else
   if ~exists('grocer_b','local') then
      grocer_b=[]
   end
 
   if grocer_indvecy ~= [] then
      grocer_y=ones(size(grocer_vecy,1),grocer_ny)
      grocer_y(:,grocer_indvecy)=grocer_vecy
   else
// y=cte
      grocer_y=ones(grocer_nobs,1)
   end
 
end
 
ncte=size(grocer_indctey,2)
if ncte > 1 then
   warning('you have more than one constant in the list of your variables')
   write(%io(2),'only the first one has been considered','(a)')
   grocer_y(:,(2:$))=[]
end
 
if grocer_testna then
 
   grocer_presna=find(or(isnan(grocer_y),'r'))
   for i=1:size(grocer_presna,2)
      error('series '+grocer_namexos(grocer_namey(i))+' contains Nan in the range you have specified')
   end
end
 
endfunction
 
