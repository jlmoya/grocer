function statement=gauss2sci_loops(statement,op)
 
// PURPOSE: in a statement, translate gauss loops into Scilab
// ones
// ------------------------------------------------------------
// INPUT:
// * statement = a (1 x K) vector, stemming from a gauss
//   statement sperated between string and non string
//   components
// ------------------------------------------------------------
// OUTPUT:
// * statement = the same statement but with Scilab loops
//   definitions
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
 
statk=statement(1)
[true_do,ind_do_def,statk]=findobject(convstr(statk),'do',[' '],[' '],%f)
if true_do then
   k=ind_do_def(1)+4
   while part(statk,k) == ' ' then
      statk=part(statk,1:k-1)+part(statk,1:k+1)
   end
   [true_while,ind_while_def,statk]=findobject(convstr(statk),'do while',[' '],[' ';'('],%f)
   if true_while then
      statement(1)=strsubst(statk,'do while','while')
   else
      pres_until=findobject(convstr(statk),'do until',[' '],[' ';'('],%f)
      if pres_until then
         statement(1)=strsubst(statk,'do until ','while ~(')
         statement($)=part(statement($),1:length(statement($))-1)+');'
      end
   end
elseif part(stripblanks(statk),1:4) == 'for ' then
   ind_for=strindex(statk,'for ')
   statk_end=part(statk,ind_for(1)+4:length(statk))
   [start_count,end_count]=delineate(statk_end,'(',')')
       list_arg=extract_arg(part(statk_end,start_count+1:end_count-1),',',['(';'['],[')';']'],''"')
 
       statement(1)=part(statement(1),1:ind_for+2+start_count)+'='+list_arg(1)+':'+list_arg(3)+...
                    ':'+list_arg(2)+';'
end
 
endfunction
