function [statement,type_statement]=gauss2sci_rep_let(statement,type_statement,ind_length,ind_let)
 
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
// type 'string' can be given in Gauss: remove it into Scilab
statement=strsubst(statement,' string ',' ')
indeq=strindex(statement,'=')
 
if isempty(indeq) then
// the declared matrix is 0;
// let x; ==> x=0
// let x[p,q] ==> x=zeros(p,q);
   ind_leftbrack=strindex(statement,'[')
   ind_rightbrack=strindex(statement,']')
   if isempty(ind_leftbrack) then
      stat=part(statement,ind_let+4:ind_length(2)-1)+'=0;'
   else
      stat=part(statement,ind_let+4:ind_leftbrack-1)+'=zeros('+...
      part(statement,ind_leftbrack+1:ind_rightbrack-1)+');'
   end
 
else
// the declared matrix is defined by the lhs of the equality
 
   end_left=indeq(1)-1
   statement=strsubst(statement,'...',' ... ')
   statement_before=part(statement,1:end_left)
   statement_before=strsubst(statement_before,'let ','')
   statement_after=stripblanks(part(statement,indeq+1:length(statement)-1))
 
   if part(statement_after,1) == '{' then
   // the matrix is declared in extenso by the values between braces
   // e.g let x= {1 2 3 , 4 5 6} ==> x=[1 2 3 ;4 5 6]
      statement_end=strsubst(statement_after,'{','[')+';'
      statement_end=strsubst(statement_end,'}',']')+';'
      statement_end=strsubst(statement_end,',',';')+';'
 
   else
 
      // first searches for the elements of the matrix: they are
      // found between blanks: the first non blank character before a blank
      // marks the end of an element
      statement_after=strsubst(statement_after,'...',' ')
      blank=[0 strindex(statement_after,' ') length(statement_after)+1]
      dblank=blank(2:$)-blank(1:$-1)
      [junk,index]=find(dblank~=1)
      ind_end=blank(index+1)-1
 
 
      // and the first non blank character after a blank
      // marks the start of an element
      nonblank=1:length(statement_after)
      nonblank(blank(2:$-1))=[]
      nonblank=[1 nonblank length(statement_after)+1]
      dnonblank=nonblank(2:$)-nonblank(1:$-1)
      [junk,index]=find(dnonblank ~= 1)
      nonblank=nonblank(2:$)
      ind_start=nonblank(index)
 
      list_elem=[]
      // build a column matrix with all elements
      for i=1:size(ind_start,2)
          elem=part(statement_after,ind_start(i):ind_end(i))
          if (ascii(part(elem,1)) < 48 | ascii(part(elem,1)) > 57) & ...
             part(elem,1) ~= '.' & part(elem,1) ~= ''"' then
             elem=""""+convstr(elem,'u')+""""
          end
          list_elem=[list_elem ; elem]
      end
 
      nelem=size(list_elem,1)
      ind_lefbracket=strindex(statement_before,'[')
      if isempty(ind_lefbracket) then
      // the matrix is a column vector defined by the
      // elements in the rhs
         statement_end='['+strcat(list_elem,';')+'];'
 
      else
      // the matrix dimensions are defined between the brackets in the lhs
 
         execstr('size_mat='+part(statement_before,ind_lefbracket:...
               strindex(statement_before,']')))
         statement_before=part(statement_before,1:ind_lefbracket-1)
 
         if nelem == 1 then
         // all entries in the matrix are the same, defined by
         // the rhs value
            statement_end=elem+'*ones('+strcat(string(size_mat),',')+');'
 
         else
            k=1
            statement_end='['+strcat(list_elem(1:size_mat(2)),',')
            // fill the rows of the matrix with the successive elements
            // found in the rhs
            for i=2:size_mat(1)
               statement_end=statement_end+' ; '+strcat(list_elem(1+(i-1)*size_mat(2):i*size_mat(2)),' , ')
            end
            statement_end=statement_end+'];'
         end
      end
 
   end
 
   stat=statement_before+'='+statement_end
 
end
 
// transform the statement back into its string-nostring parts
ind_quotes=[strindex(stat,''"') length(stat)+1]
statement=[]
type_statement=[]
for i=(size(ind_quotes,2)-1)/2:-1:1
   statement=[part(stat,ind_quotes(2*i-1):ind_quotes(2*i)) ...
              part(stat,ind_quotes(2*i)+1:ind_quotes(2*i+1)-1) statement]
   type_statement=['string' 'nostring' type_statement]
end
 
if ind_quotes(1) ~= 1 then
   statement=[part(stat,1:ind_quotes(1)-1) statement]
   type_statement=['nostring' type_statement]
 
end
 
 
endfunction
 
