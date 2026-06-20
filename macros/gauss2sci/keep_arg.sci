function statk=keep_arg(statk,namefunc,args,before_f,after_f)
 
// PURPOSE: keep in the definition a function only part of its
// arguments
// ------------------------------------------------------------
// INPUT:
// * statk = a gauss statement
// * namefunc = name of the function to deal with
// * args = place of the arguments to keep
// * before_f = a string vector: what character must be found
//   before the function
// * after_f = a string vector: what character must be found
//   after the name of the function
// ------------------------------------------------------------
// OUTPUT:
// * gauss2sci_matout
// * namefunc = the name of the function
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
[true_func,ind_func,statk]=findobject(statk,namefunc,before_f,after_f,%t)
// remove the third argument of func, useless in Scilab
for i=size(ind_func,1):-1:1
   ind_func_i=ind_func(i)
   statk_end=part(statk,ind_func_i:length(statk))
   [start_func,end_func]=delineate(statk_end,'(',')')
   list_arg=extract_arg(part(statk_end,start_func+1:end_func-1),',',['(';'['],[')';']'],''"')
   statk=part(statk,1:ind_func_i-1+start_func)+strcat(list_arg(args),',')+...
        part(statk,ind_func_i-1+end_func:length(statk))
end
 
endfunction
