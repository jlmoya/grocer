function [statements,type_statements,commentsf,comment_startf,comment_endf,state_start,state_end]=gauss2sci_rep_all(statements,type_statements,commentsf,comment_startf,comment_endf,state_start,state_end)
 
// PURPOSE: transform Gauss statements into their Scilab
// translation
// ------------------------------------------------------------
// INPUT:
// * statements = a list of statements, dissected between
//   their string and non string components
// * type_statements = a list of string 'string' and 'nostring'
//   indicating the type of the statement components
// ------------------------------------------------------------
// OUTPUT:
// * statements = a list of statements, dissected between
//   their string and non string components
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
n_statements=length(statements)
i_stat=0
ind_statements=1:n_statements
 
 
while i_stat < n_statements
   i_stat=i_stat+1
   statement=statements(i_stat)
   statshort=strsubst(strsubst(strsubst(statement,' ',''),ascii(9),''),ascii(32),'')
 
   if or(~isempty(statshort)) then
 
      if grocer_verbose then
         write(%io(2), strcat(statements(i_stat)),'(a)')
      end
 
      statement(1)=strsubst_trueobj(statement(1),'load ','loadm ',[' '],[],%f)
      stat1=statement(1)
      skeleton=stripblanks(strsubst(stat1,';',''))
      type_statement=type_statements(i_stat)
      [statement,type_statement,ind_length]=gauss2sci_rep_prologue(statement,type_statement)
 
      [true_let,ind_let]=findobject(convstr(stat1),'let ',[' '],[],%f)
      [true_declare,ind_declare]=findobject(convstr(stat1),'declare ',[' '],[],%f)
      [true_loadm,ind_loadm]=findobject(convstr(stat1),'loadm ',[' '],[],%f)
      [true_format,ind_format]=findobject(convstr(stat1),'format ',[' '],[],%f)
      [true_output,ind_output]=findobject(convstr(stat1),'output ',[' '],[],%f)
      [true_include]=findobject(convstr(stat1),'#include ',[' ' ],[],%f)
      [true_library]=findobject(convstr(stat1),'library ',[' ' ],[],%f)
 
      if true_let & type_statement(1) == 'nostring' then
 
         [statement,type_statement]=gauss2sci_rep_let(statement,type_statement,ind_length,ind_let)
         statements(i_stat)=statement
         ind_statements(ind_statements == i_stat)=[]
//         type_statements(i_stat)=type_statement
 
      elseif true_declare & type_statement(1) == 'nostring' then
         [statements,type_statements,commentsf,comment_startf,comment_endf,state_start,state_end]=....
         gauss2sci_rep_declare(statement,type_statement,ind_length,ind_declare,statements,i_stat,commentsf,comment_startf,comment_endf,state_start,state_end)
         i_stat=i_stat+1
         n_statements=n_statements+1
         if or(ind_statements > i_stat) then
            ind_statements=[ind_statements(ind_statements < i_stat) ind_statements(ind_statements > i_stat)+1]
         end
 
      elseif true_loadm & type_statement(1) == 'nostring' then
         statement=strsubst_trueobj(statement,'loadm','loadm(''',[' '],[' '; '=']',%f)
         statement=part(statement,1:length(statement)-1)+''')'
         statements(i_stat)=statement
         ind_statements(ind_statements == i_stat)=[]
 
      elseif true_format & type_statement(1) == 'nostring' then
         statement=strsubst_trueobj(strcat(statement),'format','format_gauss(''',[' '],[' '; '=']',%f)
         statement=part(statement,1:length(statement)-1)+''')'
         statements(i_stat)=statement
         ind_statements(ind_statements == i_stat)=[]
 
      elseif true_output & type_statement(1) == 'nostring' then
         statement=strsubst_trueobj(strcat(statement),'output','output_gauss(''',[' '],[' '],%f)
         statement=part(statement,1:length(statement)-1)+''')'
         statements(i_stat)=statement
         ind_statements(ind_statements == i_stat)=[]
 
      elseif (true_include | true_library) & type_statement(1) == 'nostring' then
         comment_warn='// !! statement: '"'+strcat(statement)+''" has not put into comment'
         statements(i_stat)='// not translated: '+strcat(statement)
         ind_statements(ind_statements == i_stat)=[]
 
      else
 
         if isempty(skeleton) & size(statement,2) > 1 then
            statement(1)=statement(1)+'print '
         end
         // remove the retp component, because of the diffrent meaning of parentheses
         [statement,type_statement,stat0,statinf,ind_length,ind_statements]=gauss2sci_retp2statement(statement,type_statement,ind_length,i_stat,ind_statements)
         ind_nostring=find(type_statement == 'nostring')
         statements(i_stat)=statement
         type_statements(i_stat)=type_statement
         [statement,ind_statements]=gauss2sci_graphs(statement,i_stat,ind_statements)
 
         [op,ind_nonempty]=gauss2sci_ind_operators(statement,type_statement,ind_length)
         nop_simple=size(op('plus'),2)+size(op('minus'),2)+size(op('equal'),2)+size(op('star'),2)
         nop_par=size(op('fuspar'),2)+size(op('fusbrack'),2)
 
         if size(op('all'),2) == nop_simple & nop_par == 0 & and(type_statement ~= 'string') then
            // the statement contains only variable names, operators that have
            // the same functionning in Gauss and Scilab or simple instructions
            [statements,type_statements,commentsf,comment_startf,comment_endf,state_start,state_end,add_stat,ind_statements]=...
            gauss2sci_rep_simple(statement,statements,type_statements,i_stat,state_start,state_end,comment_startf,comment_endf,ind_statements)
            [statement,op,ind_statements]=gauss2sci_rep_misc(statement,type_statement,op,i_stat,ind_statements)
            i_stat=i_stat+add_stat
            n_statements=n_statements+add_stat
            statements(i_stat)=stat0+strsubst(statements(i_stat),'$+',' +')+statinf+';'
 
         else
 
            [statement,op,ind_length]=gauss2sci_add_brackets(statement,op,ind_length)
            [statement,op,ind_length]=gauss2sci_rep_operations(statement,op,ind_length)
            ind_nostring=find(type_statement == 'nostring')
 
            for elem=ind_nostring
               statement_elem=statement(elem)
               [statement_elem,op,ind_length]=gauss2sci_strsubst(statement_elem,'&','foo_',op,ind_nonempty,ind_length,elem)
 
               op_all=op('all')
               op_all(3,op_all(4,:) == 12 & op_all(2,:) == elem)=11
               op('all')=op_all
 
               statement_elem=strsubst(statement_elem,'$',' ')
               statement_elem=strsubst(statement_elem,'{','[')
               statement_elem=strsubst(statement_elem,'}',']')
 
               statement_elem=gauss2sci_rep_dist(statement_elem)
               statement_elem=gauss2sci_rep_keyw(statement_elem)
               statement_elem=gauss2sci_rep_statistics(statement_elem)
               [statement_elem,ind_statements]=gauss2sci_rep_io(statement_elem,i_stat,ind_statements)
               statement(elem)=statement_elem
               ind_length=cumsum([0 length(statement)])
               [statement,type_statement]=gauss2sci_rep_string(statement,type_statement,elem,op,ind_length)
            end
 
            ind_length=cumsum([0 length(statement)])
            [op,ind_nonempty]=gauss2sci_ind_operators(statement,type_statement,ind_length)
 
            [true_print,ind_print_def,statk]=findobject(convstr(statement(1)),'print',[' '],[' ' ; '""' ;';'],%f)
            if true_print then
               [statement,type_statement,op,ind_nonempty,ind_fusbrack_nonmat]=gauss2sci_print(statement,type_statement,op,ind_nonempty,ind_print_def)
               ind_statements(ind_statements == i_stat)=[]
            else
               [statement,ind_length,op]=gauss2sci_mat(statement,type_statement,ind_length,op)
            end
 
            ind_length=cumsum([0 length(statement)])
            [statement,op,ind_length]=gauss2sci_rep_matfunc(statement,op,ind_nonempty,ind_length) // transforms some matrix functions
            [statement,ind_length,op,ind_statements]=gauss2sci_cond(statement,type_statement,ind_length,op,ind_statements)
            [statement,op,ind_statements]=gauss2sci_rep_misc(statement,type_statement,op,i_stat,ind_statements)
 
 
            // the replacement comes at the end, because I introduce Scilab tilde
            // which must not be taken for a Gauss tilde dealt with in function
            // gauss2sci_mat
            for elem=ind_nostring
               statement_elem=statement(elem)
               statement_elem=gauss2sci_loops(statement_elem)
               [statement_elem,op,ind_length]=gauss2sci_strsubst(statement_elem,'.le ','<=',op,ind_nonempty,ind_length,elem)
               [statement_elem,op,ind_length]=gauss2sci_strsubst(statement_elem,'.lt ','<',op,ind_nonempty,ind_length,elem)
               [statement_elem,op,ind_length]=gauss2sci_strsubst(statement_elem,'.eq ','==',op,ind_nonempty,ind_length,elem)
               [statement_elem,op,ind_length]=gauss2sci_strsubst(statement_elem,'.ne ','~=',op,ind_nonempty,ind_length,elem)
               [statement_elem,op,ind_length]=gauss2sci_strsubst(statement_elem,'.ge ','>=',op,ind_nonempty,ind_length,elem)
               [statement_elem,op,ind_length]=gauss2sci_strsubst(statement_elem,'.gt ','>',op,ind_nonempty,ind_length,elem)
               [statement_elem,op,ind_length]=gauss2sci_strsubst(statement_elem,'.and ',' & ',op,ind_nonempty,ind_length,elem)
               [statement_elem,op,ind_length]=gauss2sci_strsubst(statement_elem,'.or ',' | ',op,ind_nonempty,ind_length,elem)
               statement_elem=gauss2sci_matfunc_addr(statement_elem,'cumsumc',emptystr())
               statement_elem=gauss2sci_matfunc_addr(statement_elem,'cumprodc',emptystr())
               statement_elem=gauss2sci_matfunc_addr(statement_elem,'prodc','''')
               statement_elem=gauss2sci_matfunc_addr(statement_elem,'sumc','''')
               statement_elem=gauss2sci_matfunc_addr(statement_elem,'meanc','''')
               statement(elem)=statement_elem
               statement_elem=gauss2sci_imaginary(statement_elem)
            end
 
            statement(1)=stat0+statement(1)
            statement($)=part(statement($),1:length(statement($))-1)+statinf+';'
            statements(i_stat)=statement
            type_statements(i_stat)=type_statement
 
         end
 
      end
   end
end
 
[statements,type_statements]=gauss2sci_comp_print(statements,ind_statements,type_statements)
 
endfunction
 
