function ind_obj_def=find_log(vi)
 
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
 
 
ind_obj = strindex(vi,'log')
true_obj=%f
ind_obj_def=[]
wi=' '+vi
 
for i=size(ind_obj,'*'):-1:1
   ind_obji=ind_obj(i)
   ind_afterobji=part(vi,ind_obji+3)
   if or(part(wi,ind_obji) == ['+' ;'-';'*';'/';' ';'^';'=';'(';',']) & or(ind_afterobji == [' '; '(']) then
      true_obj=%t
      ind_obj_def=[ind_obji ind_obj_def]
   end
end
 
endfunction
