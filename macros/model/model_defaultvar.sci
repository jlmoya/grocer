function name_var_eq=model_defaultvar(eq,codevar)
 
// PURPOSE: in a string, find variables type when defined
// by a suffix
// ------------------------------------------------------------
// INPUT:
// * eq = a string (an equation)
// * codevar = a string, the suffix used to mark a variable
// ------------------------------------------------------------
// OUTPUT:
// * name_var_eq = a string vetcor, collecting the names of
//   variables marked by the user-defined suffix
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014-2015
// http://grocer.toolbox.free.fr/grocer.html
 
name_var_eq=[]
speccar=['+' , '-' , '*' , '/' , '^' , '=' , '(' , ' ' , ascii(9)]
ind_var=strindex(eq,codevar)
 
for k=size(ind_var,2):-1:1
   ind_beforevar=[]
   for h=1:size(speccar,2)
      ind_beforevar=[ind_beforevar strindex(eq,speccar(h))]
   end
   ind_beforevar=gsort(ind_beforevar,'g','i')
   auxil=find(ind_beforevar < ind_var(k))
   name_coeffk=stripblanks(part(eq,ind_beforevar(auxil($))+1:ind_var(k)-1))
   name_var_eq=[name_var_eq ; name_coeffk]
end
name_var_eq=unique(name_var_eq)
 
endfunction
