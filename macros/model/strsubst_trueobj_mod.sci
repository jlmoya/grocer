function txt=strsubst_trueobj_mod(txt,obj1,obj2)
 
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
// * true_obj = a boolean indicating whether the object has
//   been found
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
 
//ind_obj_def=findobject_mod(txt,obj1)
//length_obj=length(obj1)
//
//for j=size(ind_obj_def,2):-1:1
//   txt=part(txt,1:ind_obj_def(j)-1)+obj2+part(txt,ind_obj_def(j)+length_obj:length(txt))
//end
 
ind_obj = strindex(txt,obj1)
wi=' '+txt+' '
length_obj1=length(obj1)
 
for i=size(ind_obj,'*'):-1:1
   ind_obji=ind_obj(i)
   if or(part(wi,ind_obji) == ['+' ;'-';'*';'/';' ';'^';'=';'(';',']) & ...
       or(part(wi,ind_obji+length(obj1)+1) == ['+' ;'-';'*';'/';' ';'^';'=';')';',']) then
      txt=part(txt,1:ind_obji-1)+obj2+part(txt,ind_obji+length_obj1:length(txt))
   end
end
 
endfunction
 
