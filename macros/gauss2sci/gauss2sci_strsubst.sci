function [txt,op,ind_length]=gauss2sci_strsubst(txt,obj1,obj2,op,ind_nonempty,ind_length,elem)
 
// PURPOSE: susbititue obj2 to obj1 in string txt and update
// the operator tlist indexes the cumumated length of the
// statement elements
// ------------------------------------------------------------
// INPUT:
// * vi = a string
// * obj1 = a string to substitue in txt
// * obj2 = the new string
// * op = the tlist of operators indexes
// * ind_nonempty = the indexes of the non empty elements in
//   the tlist op
// * ind_length = the vector of cumumated length of the
//   statement elements
// * elem = a scalar, the index of the considered element
// ------------------------------------------------------------
// OUTPUT:
// * txt = the new txt
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
 
ind_obj_def=strindex(txt,obj1)
 
for j=size(ind_obj_def,2):-1:1
   length_obj=length(obj1)
   diff_length=length(obj2)-length_obj
   txt=part(txt,1:ind_obj_def(j)-1)+obj2+part(txt,ind_obj_def(j)+length_obj:length(txt))
   op=shift_op(op,ind_nonempty,ind_obj_def(j)+ind_length(elem),diff_length)
   ind_length(elem+1:$)=ind_length(elem+1:$)+diff_length
end
 
endfunction
 
