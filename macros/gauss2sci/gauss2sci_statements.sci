function [txt,statements,type_statements,state_start,state_end]=gauss2sci_statements(txt,comments_start,comments_end)
 
// PURPOSE: build a matrix of statements from a gauss file
// ------------------------------------------------------------
// INPUT:
// * txt= a string, the text of a gauss function or script
// * comments_start = a (k x 2) real matrix reporting the
//   lines (first column) and column (second column) where a
//   block of comments starts
// * comments_end = a (k x 2) real matrix reporting the
//   lines (first column) and column (second column) where a
//   block of comments ends
// ------------------------------------------------------------
// OUTPUT:
// * txt = the orginal text, with '...' added at the end of
//   lines not ended by a ';'
// * statements = a list of column string vectors, each element
//   in the list is a complete statement, cut into string and
//   non string parts
// * type_statements = a list of column string vectors, each
//   element in the list is the vector of the types for the
//   corresponding parts of statements
// * state_start = a (N x 2) integer matrix; the first
//   column gathers the starting row, the second the
//   position in the row of the statement start
// * state_end = a (N x 2) integer matrix; the first
//   column gathers the ending row, the second the
//   position in the row of the statement end
// ------------------------------------------------------------
// NOTES:
// * a statement is necessarily ended by a ';', which allows to
//  isolate statements relatively easily
// * the difficulty is that a ';' can be found also in a string
//   and this is why I have to search also for quotes
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
 
[txt,blockstate_start,blockstate_end]=gauss2sci_blockstates(txt,comments_start,comments_end)
state_start=[]
state_end=[]
statements=list()
type_statements=list()
 
for j=1:size(blockstate_start,1)
 
   statement_j=[]
   type_statement_j=[]
   i=blockstate_start(j,1)
   endblock=blockstate_end(j,1)
   state_start=[state_start ; blockstate_start(j,:)]
   ended=%f
   line=txt(blockstate_start(j,1))
   // first line
   if blockstate_end(j,1) == blockstate_start(j,1) then
      // the block of statements has only one line: the first
      // line ends at the end of the block
      line_i=part(line,blockstate_start(j,2):blockstate_end(j,2))
   else
      line_i=part(line,blockstate_start(j,2):length(line))
   end
 
   while ~ended then
 
      ind_quotes=strindex(line_i,''"')
      ind_semicol=strindex(line_i,';')
 
      if isempty(ind_quotes) & isempty(ind_semicol) then
      // this is a case when the line is empty, blank or covers several lines
         line_i2=strsubst(line_i,' ','')
         line_i2=strsubst(line_i2,ascii(9),'')
 
         if isempty(statement_j) & isempty(line_i2) then
         // this a case when the statement is a white line
 
            state_end=[state_end ; i length(line_i)]
            statements($+1)=line_i
            type_statements($+1)='nostring'
            i=i+1
            statement_j=[]
            type_statement_j=[]
 
            if i > endblock then
               ended=%t
            elseif i==endblock then
               state_start=[state_start ; i 1]
               line_i=part(txt(i),1:blockstate_end(j,2))
           else
               state_start=[state_start ; i 1]
               line_i=txt(i)
            end
 
         elseif isempty(statement_j) then
            statement_j=line_i
            type_statement_j='nostring'
            i=i+1
            if i > endblock then
               ended=%t
            elseif i == endblock then
               line_i=part(txt(i),1:blockstate_end(j,2))
            else
               line_i=txt(i)
            end
 
         else
         // case when:
         // - either the statement covers several lines, therefore
         // add the line to the open statement
         // - the line is blank before a comment
            statement_j($)=statement_j($)+line_i
            i=i+1
            if i > endblock then
               type_statements($+1)='nostring'
               statements($+1)=statement_j
               state_end=[state_end ; i-1 length(line_i)]
               ended=%t
            elseif i == endblock then
               line_i=part(txt(i),1:blockstate_end(j,2))
            else
               line_i=txt(i)
            end
         end
 
      elseif isempty(ind_quotes) then
         // the ';' ends the statement; go to the next statement
         // or end the search if there is no statement left,
         // that is the next line is after the end of the block
         // of statements
 
         if type_statement_j($) == 'string' then
            type_statement_j=[type_statement_j 'nostring']
            statement_j=[statement_j part(line_i,1:ind_semicol(1))]
         elseif isempty(statement_j) then
            statement_j=part(line_i,1:ind_semicol(1))
            type_statement_j='nostring'
         else
            statement_j($)=statement_j($)+part(line_i,1:ind_semicol(1))
         end
 
         statements($+1)=statement_j
         type_statements($+1)=type_statement_j
         state_end=[state_end ; i ind_semicol(1) ]
         line_i=part(line_i,ind_semicol(1)+1:length(line_i))
         statement_j=[]
         type_statement_j=[]
 
         if isempty(strsubst(line_i,' ','')) then
            i=i+1
            if i == endblock then
               state_start=[state_start ; i 1]
               line_i=part(txt(i),1:blockstate_end(j,2))
            elseif i < endblock then
               state_start=[state_start ; i 1]
               line_i=txt(i)
            else
               ended=%t
            end
         else
            state_start=[state_start ; i ind_semicol(1)+1]
         end
 
      elseif isempty(ind_semicol) then
         if size(ind_quotes,2) > 1 then
            if ind_quotes(1) == 1 then
               statement_j=[statement_j , strsubst(part(line_i,ind_quotes(1):ind_quotes(2)),'''','''''') ]
               type_statement_j=[type_statement_j , 'string']
            else
               statement_j=[statement_j , part(line_i,1:ind_quotes(1)-1) , strsubst(part(line_i,ind_quotes(1):ind_quotes(2)),'''','''''') ]
               type_statement_j=[type_statement_j , 'nostring' , 'string']
            end
            line_i=part(line_i,ind_quotes(2)+1:length(line_i))
         else
            i=i+1
            if ind_quotes ~= 1 then
               statement_j=[statement_j , part(line_i,1:ind_quotes(1)-1) ]
               type_statement_j=[type_statement_j , 'nostring' ]
            end
            line_i=part(line_i,ind_quotes:length(line_i))+txt(i)
         end
 
      elseif ind_quotes(1) < ind_semicol(1) then
      // there is a quote before the ';'; find the ending quote
      // add the text between quotes to the statement and removes
      // it from the line
         if size(ind_quotes,2) > 1 then
            if ind_quotes(1) == 1 then
               statement_j=[statement_j , strsubst(part(line_i,ind_quotes(1):ind_quotes(2)),'''','''''') ]
               type_statement_j=[type_statement_j , 'string']
            else
               statement_j=[statement_j , part(line_i,1:ind_quotes(1)-1) , strsubst(part(line_i,ind_quotes(1):ind_quotes(2)),'''','''''') ]
               type_statement_j=[type_statement_j , 'nostring' , 'string']
            end
            line_i=part(line_i,ind_quotes(2)+1:length(line_i))
         end
 
 
      else
         // the ';' ends the statement; go to the next statement
         // or end the search if there is no statement left,
         // that is the next line is after the end of the block
         // of statements
         state_end=[state_end ; i ind_semicol(1) ]
         if type_statement_j($) == 'string' | isempty(statement_j) then
            type_statement_j=[type_statement_j 'nostring']
            statement_j=[statement_j part(line_i,1:ind_semicol(1))]
         else
            statement_j($)=statement_j($)+strsubst(part(line_i,1:ind_semicol(1)),'''','''''')
         end
         statements($+1)=statement_j
         type_statements($+1)=type_statement_j
         line_i=part(line_i,ind_semicol(1)+1:length(line_i))
         statement_j=[]
         type_statement_j=[]
 
         if isempty(strsubst(line_i,' ','')) then
            i=i+1
            if i == endblock then
               state_start=[state_start ; i 1]
               line_i=part(txt(i),1:blockstate_end(j,2))
            elseif i < endblock then
               state_start=[state_start ; i 1]
               line_i=txt(i)
            else
               ended=%t
            end
         else
            state_start=[state_start ; i ind_semicol(1)+1]
         end
      end
   end
end
 
endfunction
