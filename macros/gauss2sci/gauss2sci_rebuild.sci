function textf=gauss2sci_rebuild(statements,state_start,commentsf)
 
// PURPOSE: gather translated statements and comments into the
// translated Scilab function
// ------------------------------------------------------------
// INPUT:
// * statements = a (n1 x 1) vector of statements
// * state_start = a (n1 x 1) vector indicating the starting
//   line of the statements
// * commentsf = a (n2 x 1) vector of comments
// ------------------------------------------------------------
// OUTPUT:
// * NOTHING: the result is stored in a .sci file
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
textf=emptystr(size(commentsf,1),1)
 
i=1
while i <= length(statements)
   statement_i=strcat(statements(i),'')
 
   statef=[]
   ind_newline=strindex(statement_i,'...')
   while ~isempty(ind_newline) then
      statef=[statef ; part(statement_i,1:ind_newline(1)-1)+' ...']
      statement_i=part(statement_i,ind_newline(1)+4:length(statement_i))
      ind_newline=strindex(statement_i,'...')
   end
   statef= [statef ; statement_i]
   nlines=size(statef,1)
   textf(state_start(i,1)+[0:nlines-1])=textf(state_start(i,1)+[0:nlines-1])+statef
   i=i+1
end
 
textf=textf+commentsf
 
endfunction
