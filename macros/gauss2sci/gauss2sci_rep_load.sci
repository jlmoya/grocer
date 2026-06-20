function [stat]=gauss2sci_rep_load(statement,type_statement,ind_length)
 
// PURPOSE: transform Gauss miscellaneous functions
// ------------------------------------------------------------
// INPUT:
// * statement = a (1 x K) vector, stemming from a gauss
//   statement sperated between string and non string
//   components
// * type_statement = a (1 x K) vector, indicating if the
//   corresponding statement component is a string or not
// * ind_length = a (1 x (K+1)) vector, starting with 0 and
//   then indicating the cumulated length of the statement
//   components
// ------------------------------------------------------------
// OUTPUT:
// * statement = the same statement but with Scilab
//   definitions for conditionals
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
statement=strcat(statement,'')
statement=strsubst(statement,'loadm','load_gaussm(''')
ind_comma=strindex(statement,',')
ind_leftbrack=strindex(statement,'[')
ind_rightbrack=strindex(statement,']')
for i=1:size(ind_leftbrack,2)
   ind_li=ind_leftbrack(i)
   ind_ri=ind_rightbrack(i)
   ind_comma(ind_li<ind_comma & ind_comma<ind_ri)=[]
end
 
length_stat=length(statement)
stat=part(statement,1:length_stat-1)+''');'
if ~isempty(ind_comma) then
   ncomma=size(ind_comma,2)
   for j=ncomma:-1:1
      stat=part(stat,1:ind_comma(j)-1)+''','''+part(statement,ind_comma(j)+1:length(statement))
   end
end
 
endfunction
 
