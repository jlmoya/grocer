function [true_obj,ind_obj_def,vi]=findobject(vi,obj,before,after,suppr_blank)
 
// PURPOSE: find the "true" string obj in the string vi
// ------------------------------------------------------------
// INPUT:
// * vi = a string
// * obj = a string to seacrh in vi
// * before = a string vector: what character must be found
//   before vi
// * after = a string vector: what character must be found
//   after vi
// * suppr_blank = a booelan indicating whether blanks count
//   or not (optional: default =%f)
// ------------------------------------------------------------
// OUTPUT:
// * true_obj = a booelan indicating if the object has been
//   found
// * ind_obj = a row vector, the indexes of the object in the
//   string
// * vi = the original string, eventually with blanks after the
//   keyword suppressed
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009-2015
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
 
if nargin < 5 then
   suppr_blank=%f
end
 
true_obj=%f
ind_obj_def=[]
length_obj=length(obj)
wi=' '+vi+' '
ind_obj = strindex(wi,obj)
 
after=[after ; ' ']
before=[before ; ' ']
for i=size(ind_obj,'*'):-1:1
   ind_obji=ind_obj(i)
   ind_afterobji=part(wi,ind_obji+length_obj)
 
   if or(ind_afterobji == after) & or(part(wi,ind_obji-1) == before) then
      true_obj=%t
      ind_obj_def=[ind_obji-1 ind_obj_def ]
      if suppr_blank & ind_obji+length_obj ~= length(vi) then
         // suppress all blanks after the searched keyword
         while ind_obji+length_obj <= length(vi) & part(vi,ind_obji+length_obj-1) == ' ' then
            vi=part(vi,1:ind_obji+length_obj-2)+part(vi,ind_obji+length_obj:length(vi))
         end
      end
   end
 
end
 
endfunction
