function [statements,type_statements,commentsf,comment_startf,comment_endf,state_start,state_end]=gauss2sci_rep_declare(statement,type_statement,ind_length,ind_dec,statements,i_stat,commentsf,comment_startf,comment_endf,state_start,state_end)
 
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
indeq=strindex(statement,'=')
 
if isempty(indeq) then
// the declared matrices are 0;
// let x; ==> x=0
// let x[p,q] ==> x=zeros(p,q);
   statement=part(statement,ind_dec+7:length(statement))
   ind_struct=strindex(statement,' struct ')
   if isempty(ind_struct) then
      statement=strsubst(statement,' matrix ',' ')
      statement0=strsubst(statement,' sparse ',' ')
      [ind_leftbrack,ind_rightbrack,ind_fusbrack]=gauss2sci_find_parenth(statement0,1,ind_length,[],[],['[' ; ']'])
      ind_comma=strindex(statement,',')
      for i=size(ind_comma,2):-1:1
         ind_fusbrack_left=ind_fusbrack(:,ind_fusbrack(1,:)<ind_comma(i))
         if ~isempty(ind_fusbrack_left) then
             if ind_fusbrack_left(3,$) == 1 then
                ind_comma(i)=[]
             end
         end
      end
      ind_comma=[0 ind_comma(1,:) ind_length($)]
      comment_warn='// !! the variables '
      statement=emptystr()
      for i=1:size(ind_comma,2)-1
         stat_i=part(statement0,ind_comma(i)+1:ind_comma(i+1)-1)
         three_dots=strindex(stat_i,'...')
         dots_before=[]
         dots_after=[]
          if ~isempty(three_dots) then
            if ~isempty(stripblanks(part(stat_i,1:three_dots(1)-1)))  then
                dots_before=' ... '
            elseif ~isempty(stripblanks(part(stat_i,three_dots(1)+1:length(stat_i))))  then
                dots_after=' ... '
            end
         end
         stat_i=strsubst(stat_i,'...','')
         leftbrack_i=strindex(stat_i,'[')
         if isempty(leftbrack_i) then
            statement=statement+dots_before+'global '+stat_i+';'+stat_i+'=0;'+dots_after
            comment_warn=comment_warn+stat_i+' '
         else
            rightbrack_i=strindex(stat_i,']')
            vari=part(stat_i,1:leftbrack_i-1)
            sizes=part(stat_i,leftbrack_i+1:rightbrack_i-1)
            statement=statement+dots_before+'global '+vari+';'+vari+'=zeros('+sizes+');'+dots_after
            comment_warn=comment_warn+vari+' '
         end
      end
      comment_warn=comment_warn+' should be declared as global in any function translated from gauss that uses it'
   end
 
 
else
// the declared matrix is defined by the lhs of the equality
// type 'string' can be given in Gauss: remove it into Scilab
   statement=strsubst(statement,' string ',' ')
   statement=strsubst(statement,' matrix ',' ')
   statement=strsubst_trueobj(statement,'declare','',' ',[' '],%f,%t)
 
   indeq=strindex(statement,'=')
   end_left=indeq(1)-1
   statement=strsubst(statement,'...',' ... ')
   statement_before=part(statement,1:end_left)
   statement_after=stripblanks(part(statement,indeq+1:length(statement)-1))
 
   if part(statement_after,1) == '[' then
   // the matrix is declared in extenso by the values between braces
   // e.g let x= {1 2 3 , 4 5 6} ==> x=[1 2 3 ;4 5 6]
 
      statement_end=strsubst(statement_after,',',' ; ')
      statement_end=strsubst(statement_end,'[','[ ')
      statement_end=strsubst(statement_end,']',' ]')
 
      ind_blank=strindex(statement_end,' ')
      ind_left=strindex(statement_end,'[')
      ind_right=strindex(statement_end,']')
      ind_semicol=strindex(statement_end,';')
 
      ind_blank=ind_blank(ind_blank > ind_left & ind_blank < ind_right)
      ind_nonblank=ind_left+1:ind_right-1
      for i=1:size(ind_blank,2)
         ind_nonblank(ind_nonblank == ind_blank(i))=[]
      end
      for i=1:size(ind_semicol,2)
         ind_nonblank(ind_nonblank == ind_semicol(i))=[]
      end
 
      delta_nonblank=ind_nonblank(2:$)-ind_nonblank(1:$-1)
      [junk,ind]=find(delta_nonblank == 1)
      ind_nonblank(ind+1)=[]
 
      for i=size(ind_nonblank,2):-1:1
         start_elem=ind_nonblank(i)
         ch_start_elem=part(statement_end,start_elem)
         if (ascii(ch_start_elem) < 48 | ascii(ch_start_elem) > 57) & ...
            ch_start_elem ~= '.' & ch_start_elem ~= ''"' then
 
            [junk,ind]=find(ind_blank > ind_nonblank(i))
            end_elem=ind(1)-1
            statement_end=part(statement_end,1:start_elem-1)+'convstr('+...
                          part(statement_end,start_elem:end_elem)+',""u"")'+...
                          part(statement_end,start_elem:length(statement_end))
         end
      end
      statement_end=strsubst(statement_end,' ; ',';')
      statement_end=strsubst(statement_end,'[ ','[')
      statement_end=strsubst(statement_end,' ]',']')
 
   else
 
      // first searches for the elements of the matrix: they are
      // found between blanks: the first non blank character before a blank
      // marks the end of an element
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
         if nelem == 1 then
            statement_end=elem
         else
            statement_end='['+strcat(list_elem,';')+'];'
         end
 
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
               statement_end=statement_end+';'+strcat(list_elem(1+(i-1)*size_mat(1):i*size_mat(1)),',')
            end
            statement_end=statement_end+'];'
         end
      end
 
   end
 
   statement='global '+statement_before+';'+statement_before+'='+statement_end+';'
   comment_warn='// !! the variable '+statement_before+' should be declared as global in any function translated from gauss that uses it'
 
end
 
l=-1
while l ~= length(comment_warn) then
   l=length(comment_warn)
   comment_warn=strsubst(comment_warn,'  ',' ')
end
 
statements=lstcat(statements(1:i_stat-1),'   ',statement,statements(i_stat+1:$))
type_statements=lstcat(type_statements(1:i_stat-1),'nostring',type_statements(i_stat:$))
ind=find(comment_endf < state_start(i_stat))
 
if isempty(ind) then
   comment_startf=[state_start(i_stat) 4 ; comment_startf]
   comment_endf=[length(comment_warn)+3 ; comment_endf]
 
else
   comment_startf=[comment_startf(1:ind($),:) ; state_start(i_stat) 4 ; comment_startf(ind($)+1:$,:) ]
   comment_endf=[comment_endf(1:ind($)) ; length(comment_warn)+3 ; comment_endf(ind($)+1:$)]
 
end
 
commentsf=[commentsf(1:state_start(i_stat,1)-1) ; comment_warn ; commentsf(state_start(i_stat,1):$)]
state_start=[state_start(1:i_stat-1,:) ; state_start(i_stat,1) 1 ; state_start(i_stat:$,1)+1 state_start(i_stat:$,2) ]
state_end=[state_end(1:i_stat-1,:) ; state_start(i_stat,1) 3 ; state_end(i_stat:$,1)+1 state_end(i_stat:$,2) ]
 
endfunction
 
