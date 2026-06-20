function [txt,true_obj]=strsubst_trueobj(txt,obj1,obj2,before,after,suppr_blank,opt_convstr)
 
// PURPOSE: susbititue obj2 to obj1 in string txt provided it
// is alone or preceded by one of the characters in vector
// before and followed by one of the characters in vector
// after
// ------------------------------------------------------------
// INPUT:
// * txt = a string
// * obj1 = a string to substitue in txt
// * obj2 = the new string
// * before = a string vector: what character must be found
//   before vi
// * after = a string vector: what character must be found
//   after vi
// * suppr_blank = a booelan indicating whether blanks count
//   or not
// * opt_convstr = a booelan indicating whether the searched
//   object must be converted to lower case or not
// ------------------------------------------------------------
// OUTPUT:
// * txt = the new txt
// * true_obj = a boolean indicating whether the object has
//   been found
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009-2018
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin]=argn(0)
if nargin < 7 then
   opt_convstr=%f
end
if nargin < 6 then
   suppr_blank=%f
end
if opt_convstr then
   txt0=convstr(txt)
else
   txt0=txt
end
[true_obj,ind_obj_def]=findobject(txt0,obj1,before,after,suppr_blank)
length_obj=length(obj1)
 
for j=size(ind_obj_def,2):-1:1
   txt=part(txt,1:ind_obj_def(j)-1)+obj2+part(txt,ind_obj_def(j)+length_obj:length(txt))
end
 
endfunction
 
