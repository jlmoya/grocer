function [statement,type_statement,stat0,statinf,ind_length,ind_statements]=gauss2sci_retp2statement(statement,type_statement,ind_length,i_stat,ind_statements)
 
// PURPOSE: extract
// ------------------------------------------------------------
// INPUT:
// * statement = a statement dissected between string and non
//   string components
// * type_statement = a vector of string 'string' and 'nostring'
//   indicating the type of the statement components
// * ind_length = a (1 x N) vector of integers, with 0 in the
//   first place, then the position where the parts of the
//   statement end
// ------------------------------------------------------------
// OUTPUT:
// * statement = a statement dissected between string and non
//   string components
// * type_statement = a vector of string 'string' and 'nostring'
//   indicating the type of the statement components
// * ind_length = a (1 x N) vector of integers, with 0 in the
//   first place, then the position where the parts of the
//   statement end
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
stat1=statement(1)
[true_retp,ind_retp]=findobject(convstr(stat1),'retp',[' '],[' ';'('],%f)
 
if true_retp then
   ind_leftpar=strindex(stat1,'(')
   stat0=part(stat1,1:ind_leftpar(1))
   statement(1)=part(stat1,ind_leftpar(1)+1:length(stat1))
   ind_rightpar=strindex(statement($),')')
   statinf=part(statement($),ind_rightpar($):length(statement($))-1)
   // add a ';' at the end of the extraction
   statement($)=part(statement($),1:ind_rightpar($)-1)+';'
   ind_length(2)=ind_length(2)-ind_leftpar(1)
   ind_length($)=ind_length($)-length(statinf)
   ind_statements(ind_statements == i_stat)=[]
 
else
   stat0=emptystr()
   statinf=emptystr()
   if type_statement(1) == 'string' then
      statement=['print ' statement]
      type_statement=['nostring '  type_statement]
      ind_length=[0 6 ind_length(2:$)+6]
      ind_statements(ind_statements == i_stat)=[]
 
   elseif size(statement,2) > 1 & isempty(stripblanks(stat1)) then
      statement(1)=stat1+'print '
      ind_length(2:$)=ind_length(2:$)+6
      ind_statements(ind_statements == i_stat)=[]
 
   end
 
end
 
endfunction
 
