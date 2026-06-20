function [grocer_x,grocer_namexos,grocer_boundsvarb,grocer_prests]=explox(grocer_l,grocer_defname,grocer_boundsvarb,grocer_y,grocer_prests)
 
// PURPOSE: from a list of series retrieve their names
// or give them names if they don't have (when an
// element is not string), store the values of these series in
// a matrix, and, if necessary, update the admissible
// estimation bounds
// ------------------------------------------------------------
// INPUT:
// * grocer_l = either
//   - a list of variables
//   each element could be a timeseries, a real vector,
//   a real matrix or a string (the name of a variable with
//   one of the types cited above, between quotes)
//   - a matrix of strings, each one being the name of a
//   variable
//   - the string 'cte' or 'const' if the user wants a constant
//     to be included automatically
// * grocer_defname = default name of variables
// * grocer_boundsvarb = a (2x1) string matrix (of dates) equal
//   to the period over which to take the series (optional)
// * grocer_y = a (nobsx1) vector used when the only variable
//   in grocer_l is 'cte' or 'const'
// * grocer_prests = a boolean indicating if there is already
//   in the calling program a ts (optional: useful when explox
//   is not called first, but for instance after exploy
// ------------------------------------------------------------
// OUTPUT:
// * grocer_x = a (T x k) real matrix
// * grocer_namexos = a (1 x k) string vector
// * grocer_boundsvarb = a (2 x 1) string matrix (of dates)
// * grocer_prests = a boolean indicating whether there is a ts
// in grocer_x
// ------------------------------------------------------------
// NOTE:
// this function is used by the following functions:
// ols(), olsc(), automatic(), johansen()
// it has probably no other utility
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2004
// http://grocer.toolbox.free.fr/grocer.html
 
[grocer_nargout,grocer_nargin] = argn(0)
 
if grocer_nargin < 2 then
   error('nargin should be > 1')
 
elseif grocer_nargin == 2 then
   if exists('grocer_boundsvar') then
      grocer_boundsvarb=grocer_boundsvar
   else
      grocer_boundsvarb=[]
   end
end
 
if grocer_boundsvarb == [] then
   grocer_update=%t
else
   grocer_fqb=date2fq(grocer_boundsvarb(1))
   grocer_update=%f
end
 
if grocer_nargin < 5 then
   grocer_prests = %f
end
 
grocer_t=typeof(grocer_l)
if grocer_t == 'constant' then
   grocer_x=grocer_l
   grocer_nvar=size(grocer_l,2)
   if grocer_nvar == 1 then
      grocer_namexos=grocer_defname
   else
      grocer_namexos=grocer_defname+' # '+string([1:grocer_nvar]')
   end
   return
end
 
grocer_nexos=0
grocer_namexos=[]
grocer_nb_defname=0
 
select grocer_t
case 'list' then
   grocer_nvar=length(grocer_l)
case 'string' then
   grocer_nvar=size(grocer_l,1)*size(grocer_l,2)
   grocer_l=matrix(grocer_l,grocer_nvar,1)
case 'ts' then
   grocer_nvar=1
   grocer_l=list(grocer_l)
else
   error(grocer_t+' is an invalid type for entry in explox')
end
 
grocer_l0=grocer_l
grocer_l=list()
grocer_indcte=[]
 
// defines the name of the variables x
for grocer_i=1:grocer_nvar
   select typeof(grocer_l0(grocer_i))
 
   case 'string' then
      grocer_l0a=grocer_l0(grocer_i)
      grocer_sizel0=max(size(grocer_l0a))
      for grocer_j=1:grocer_sizel0
         if (grocer_l0a(grocer_j) == 'cte' & ~exists('cte'))...
         | (grocer_l0a(grocer_j) == 'const' & ~exists('const')) then
      // there is a constant: it is treated at the end, when the size of the
      // corresponding vector is, in any case, known
            grocer_nexos=grocer_nexos+1
            grocer_l($+1)='cte'
            grocer_indcte=[grocer_indcte grocer_nexos]
            grocer_namexos=[grocer_namexos ; grocer_l0a(grocer_j)]
         else
            grocer_l($+1)=evstr(grocer_l0a(grocer_j))
            if typeof(grocer_l($)) == 'constant' then
               grocer_nb=size(grocer_l($),2)
               if size(grocer_l($),2) == 1 then
                  grocer_namexos=[grocer_namexos ; grocer_l0(grocer_i)]
               else
                  grocer_namexos=[grocer_namexos ; grocer_l0(grocer_i)+'_'+...
                  string([grocer_nexos+1:grocer_nexos+grocer_nb]')]
               end
               grocer_nexos=grocer_nexos+grocer_nb
            else
               grocer_namexos=[grocer_namexos ; grocer_l0a(grocer_j)]
               grocer_nexos=grocer_nexos+1
            end
         end
      end
 
   case 'constant' then
      grocer_l($+1)=grocer_l0(grocer_i)
      grocer_nb=size(grocer_l0(grocer_i),2)
      grocer_namexos=[grocer_namexos ; grocer_defname+' # '+...
      string([grocer_nexos+1:grocer_nexos+grocer_nb]')]
      grocer_nexos=grocer_nexos+grocer_nb
      grocer_nb_defname=grocer_nb_defname+grocer_nb
 
   case 'ts'  then
      grocer_l($+1)=grocer_l0(grocer_i)
      grocer_nexos=grocer_nexos+1
      grocer_prests=%t
      grocer_namexos=[grocer_namexos ; grocer_defname+' # '+...
         string(grocer_nexos)]
      grocer_nb_defname=grocer_nb_defname+1
 
   end
end
 
if grocer_nb_defname == 1 then
   grocer_namexos=strsubst(grocer_namexos,grocer_defname+' # 1',grocer_defname)
end
 
for grocer_i=1:length(grocer_l)
   grocer_li=grocer_l(grocer_i)
   if typeof(grocer_li) == 'ts'  then
      grocer_fqi=freqts(grocer_li)
      if ~exists('grocer_fq','local') then
         grocer_fq=grocer_fqi
      else
         if grocer_fq ~= grocer_fqi then
            error('series '+grocer_namexos(grocer_i)+' has not the same freq as the other ts')
         end
      end
      grocer_prests=%t
      if grocer_update then
         grocer_d=datets(grocer_li)
         grocer_s=series(grocer_li)
         grocer_lna=find(~isnan(grocer_s))
         grocer_d1=grocer_d(grocer_lna(1))
      // grocer_d1 is the first non NA value
         grocer_sd=find(grocer_lna-grocer_lna(1)-[0:size(grocer_lna,2)-1]==0)
         grocer_sd=size(grocer_sd,2)
         grocer_d2=grocer_d(grocer_lna(grocer_sd))
         if grocer_boundsvarb == [] then
         // create the bounds
            grocer_boundsvarb=[num2date(grocer_d1,grocer_fq);num2date(...
              grocer_d2,grocer_fq)]
         else
            grocer_boundsvarb=[num2date(max(date2num(...
            grocer_boundsvarb(1)),grocer_d1),...
            grocer_fq);num2date(min(date2num(...
            grocer_boundsvarb(2)),grocer_d2),grocer_fq)]
         end
      else
         if grocer_fqb ~= grocer_fq then
            error('series have not the same freq as the bounds')
         end
         if grocer_nargin >= 4 then
            if typeof(grocer_y) == 'string' then
               if grocer_y == 'wna' then
                  grocer_l(grocer_i)=overlay(reshape(%nan*...
                     [1:1+date2num(grocer_boundsvarb($))-date2num(grocer_boundsvarb(1))]',...
                     grocer_boundsvarb(1)),grocer_li)
               end
            end
         end
      end
   end
end
 
// defines the matrix x
grocer_x=[]
for grocer_i=1:length(grocer_l)
   grocer_li=grocer_l(grocer_i)
   select typeof(grocer_li)
 
   case 'string' then
      if grocer_li ~= 'cte' & grocer_li ~= 'const' then
         error('too many quotes in the list of your variables')
      end
 
   case 'ts' then
      grocer_x=[grocer_x ts2vec(grocer_li,grocer_boundsvarb)]
      grocer_prests=%t
 
   case 'constant' then
      grocer_x=[grocer_x grocer_li]
 
   else
      error('exogenous variable '+grocer_namexos(grocer_i)+' is neither a timeseries nor a constant vector')
   end
 
end
 
 
// add a constant if necessary
if grocer_indcte ~= [] then
   if size(grocer_indcte,2) > 1 then
      warning('only one among the '+string(size(grocer_indcte,2))+...
      ' constants you have entered has been taken into consideration')
   end
   [nr,nc]=size(grocer_x)
   if nr == 0 then
   // the only variable is the constant
      grocer_x=0*grocer_y+1
   else
      grocer_x=[grocer_x(:,1:grocer_indcte(1)-1) ones(nr,1) ...
               grocer_x(:,grocer_indcte(1):nc)]
   end
end
 
endfunction
