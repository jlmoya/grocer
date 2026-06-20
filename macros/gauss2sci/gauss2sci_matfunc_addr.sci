function statk=gauss2sci_matfunc_addr(statk,func,transp)
 
// PURPOSE: replace the Gauss definition of a function
// with its Scilab equivalent when it is transformed by adding
// ',''r''' to the text of the inouts
// ------------------------------------------------------------
// INPUT:
// * statk = a gauss statement
// * func the name of the function
// ------------------------------------------------------------
// OUTPUT:
// * statek = the transformed gauss statement
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
before_f=[' ' ; ';' ; '=' ; '+' ; '-' ; '*' ; '/' ; '~' ; '|' ; ...
'('; '[';'^';'>';'<';'^']
after_f=[' ' ; '(' ;'[' ]
 
length_func=length(func)
[true_func,ind_func_def,statk]=findobject(convstr(statk),func,before_f,after_f,%t)
transp0=transp
 
for i=size(ind_func_def,2):-1:1
 
   transp=transp0
   ind_func_i=ind_func_def(i)
   statk_end=part(statk,ind_func_i:length(statk))
 
   select part(statk,ind_func_i+length_func)
 
   case '(' then
      [start_func,end_func]=delineate(statk_end,'(',')')
      if transp0 == '''' then
         // the result of the function is transposed
         // cancel the double transposition
         ind=end_func+1
         last=length(statk_end)
         while ind <= last & part(statk_end,ind) == ' ' then
            ind=ind+1
         end
         if part(statk_end,ind) == '''' then
            transp=''
            statk_end=part(statk_end,1:ind-1)+...
                      part(statk_end,ind+1:length(statk_end))
         end
      end
      statk=part(statk,1:ind_func_i-1)+part(func,1:length(func)-1)+...
            part(statk_end,start_func:end_func-1)+',''r'')'+transp+...
            part(statk_end,end_func+1:length(statk_end))
 
   case '[' then
      [start_func,end_func]=delineate(statk_end,'[',']')
      statk=part(statk,1:ind_func_i-1)+part(convstr(func),1:length(func)-1)+...
            part(statk,ind_func_i+length_func:ind_func_i+end_func-2)+',''r'']'+transp+...
            part(statk,ind_func_i+end_func:length(statk))
 
   end
end
 
endfunction
 
