function ind_obj_def=findobject_mod(vi,obj)
 
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
// * ind_obj = a row vector, the indexes of the object in the
//   string
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009-2015
// http://grocer.toolbox.free.fr/grocer.html
 
 
ind_obj = strindex(vi,obj)
ind_obj_def=[]
wi=' '+vi
 
for i=size(ind_obj,'*'):-1:1
   ind_obji=ind_obj(i)
   ind_afterobji=part(vi,ind_obji+length(obj))
   if or(part(wi,ind_obji) == ['+' ;'-';'*';'/';' ';'^';'=';'(';',']) & ...
       or(ind_afterobji == ['+' ;'-';'*';'/';' ';'^';'=';')';',']) then
      ind_obj_def=[ind_obji ind_obj_def]
   end
end
 
endfunction
