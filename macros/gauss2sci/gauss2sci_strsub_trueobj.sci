function [txt,op,ind_length]=gauss2sci_strsub_trueobj(txt,obj1,obj2,before,after,suppr_blank,op,ind_nonempty,ind_length,elem)
 
// PURPOSE: susbititue obj2 to obj1 in string txt provided it
// is alone or preceded by one of the characters in vector
// before and followed by one of the characters in vector
// after
// ------------------------------------------------------------
// INPUT:
// * vi = a string
// * obj1 = a string to substitue in txt
// * obj2 = the new string
// * before = a string vector: what character must be found
//   before vi
// * after = a string vector: what character must be found
//   after vi
// * suppr_blank = a booelan indicating whether blanks count
//   or not
// * convstr = a booelan indicating whether the searched object
//   must be converted to lower case or not
// ------------------------------------------------------------
// OUTPUT:
// * txt = the new txt
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
 
[true_obj,ind_obj_def]=findobject(txt,obj1,before,after,suppr_blank)
for j=size(ind_obj_def,2):-1:1
   length_obj=length(obj1)
   diff_length=length(obj2)-length_obj
   txt=part(txt,1:ind_obj_def(j)-1)+obj2+part(txt,ind_obj_def(j)+length_obj:length(txt))
   op=shift_op(op,ind_nonempty,ind_obj_def(j)+length_obj+ind_length(elem),diff_length)
   ind_length(elem+1:$)=ind_length(elem+1:$)+diff_length
end
 
endfunction
 
