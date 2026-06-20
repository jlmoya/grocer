function [op,ind_nonempty]=gauss2sci_ind_operators(statement,type_statement,ind_length)
 
// PURPOSE: store in a tlist the indexes of selected operators
// in a gauss statement
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
// * op = a tlist with each field corresponding to an operator
//   op(i) = a (4 x p) matrix:
//   - first line: the positions of the operator
//   - second line: the statement number where the operator
//     appears
//   - third line: the position of the operator end
//   - fourth line: the precedence of the operator, as
//     indicated in the table of gauss manual (chapter 11-23
//     for gauss 10 version)
// * ind_nonempty = vector of non empty operator fields
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
 
ind_leftpar=[];ind_rightpar=[];ind_bookkeep_transp=[];ind_transp=[];
ind_fact=[];ind_power=[];ind_hat=[];ind_unary=[];ind_star=[];ind_matmul=[];
ind_kron=[];ind_startilde=[];ind_slash=[];ind_matdiv=[];ind_percent=[];ind_plus=[];ind_minus=[];
ind_tilde=[];ind_pipe=[];ind_dotcond=[];ind_dotnot=[];ind_dotand=[];ind_dotor=[];
ind_dotxor=[];ind_doteqv=[];ind_diff=[];ind_inf=[];ind_infeq=[];
ind_doubleq=[];ind_sup=[];ind_supeq=[];ind_not=[];ind_and=[];
ind_or=[];ind_xor=[];ind_eqv=[];ind_column=[];ind_equal=[];ind_startcond=[];
ind_print=[];ind_comma=[];ind_leftbrack=[];ind_rightbrack=[];ind_comma=[]
 
 
ind_nostring=find(type_statement == 'nostring')
for i=ind_nostring
   stati=statement(i)
 
   [ind_leftpar,ind_rightpar,ind_fuspar]=gauss2sci_find_parenth(stati,i,ind_length,ind_leftpar,ind_rightpar,['(' ; ')'],11)
   [ind_leftbrack,ind_rightbrack,ind_fusbrack]=gauss2sci_find_parenth(stati,i,ind_length,ind_leftbrack,ind_rightbrack,['[' ; ']'],12)
 
   ind_bookkeep_transp=gauss2sci_find_simple(stati,i,ind_length,'.''',ind_bookkeep_transp,90)
   ind_transp=gauss2sci_find_simple(stati,i,ind_length,'''',ind_transp,90)
   ind_fact=gauss2sci_find_simple(stati,i,ind_length,'!',ind_fact,89)
   ind_power=gauss2sci_find_simple(stati,i,ind_length,'.^',ind_power,85)
   ind_hat=gauss2sci_find_simple(stati,i,ind_length,'^',ind_hat,85)
   ind_startilde=gauss2sci_find_simple(stati,i,ind_length,'*~',ind_startilde,80)
   ind_kron=gauss2sci_find_simple(stati,i,ind_length,'.*.',ind_kron,80)
   ind_matmul=gauss2sci_find_simple(stati,i,ind_length,'.*',ind_matmul,80)
   ind_star=gauss2sci_find_simple(stati,i,ind_length,'*',ind_star,80)
   ind_matdiv=gauss2sci_find_simple(stati,i,ind_length,'./',ind_matdiv,80)
   ind_slash=gauss2sci_find_simple(stati,i,ind_length,'/',ind_slash,80)
   ind_percent=gauss2sci_find_simple(stati,i,ind_length,'%',ind_percent,75)
   ind_plus=gauss2sci_find_simple(stati,i,ind_length,'+',ind_plus,70)
   ind_minus=gauss2sci_find_simple(stati,i,ind_length,'-',ind_minus,70)
   ind_tilde=gauss2sci_find_simple(stati,i,ind_length,'~',ind_tilde,68)
   ind_pipe=gauss2sci_find_simple(stati,i,ind_length,'|',ind_pipe,67)
 
 
   ind_dotcond=gauss2sci_find_simple(stati,i,ind_length,'.le',ind_dotcond,65)
   ind_dotcond=gauss2sci_find_simple(stati,i,ind_length,'.lt',ind_dotcond,65)
   ind_dotcond=gauss2sci_find_simple(stati,i,ind_length,'.ge',ind_dotcond,65)
   ind_dotcond=gauss2sci_find_simple(stati,i,ind_length,'.gt',ind_dotcond,65)
   ind_dotcond=gauss2sci_find_simple(stati,i,ind_length,'.ne',ind_dotcond,65)
   ind_dotcond=gauss2sci_find_simple(stati,i,ind_length,'.eq',ind_dotcond,65)
 
   ind_dotnot=gauss2sci_find_simple(stati,i,ind_length,'.not',ind_dotnot,64)
   ind_dotand=gauss2sci_find_simple(stati,i,ind_length,'.and',ind_dotand,63)
   ind_dotor=gauss2sci_find_simple(stati,i,ind_length,'.or',ind_dotor,62)
   ind_dotxor=gauss2sci_find_simple(stati,i,ind_length,'.xor',ind_dotxor,61)
   ind_doteqv=gauss2sci_find_simple(stati,i,ind_length,'.eqv',ind_doteqv,60)
 
   // find the indexes of equal keywords present in the examined part of statement
   [ind_equal,ind_doubleq,ind_diff,ind_supeq,ind_infeq]=gauss2sci_find_equal(stati,i,ind_length,ind_equal,ind_doubleq,ind_diff,ind_supeq,ind_infeq)
   ind_sup=gauss2sci_find_simple(stati,i,ind_length,'>',ind_sup,55)
   ind_inf=gauss2sci_find_simple(stati,i,ind_length,'<',ind_inf,55)
 
   // find the indexes of conditional keywords present in the examined part of statement
   ind_not=gauss2sci_find_keywd(stati,i,ind_length,'not',ind_not,[' ' ; ')'],[' ' ; '('],49)
   ind_and=gauss2sci_find_keywd(stati,i,ind_length,'and',ind_and,[' ' ; ')'],[' ' ; '('],48)
   ind_or=gauss2sci_find_keywd(stati,i,ind_length,'or',ind_or,[' ' ; ')'],[' ' ; '('],47)
   ind_xor=gauss2sci_find_keywd(stati,i,ind_length,'xor',ind_xor,[' ' ; ')'],[' ' ; '('],46)
   ind_eqv=gauss2sci_find_keywd(stati,i,ind_length,'eqv',ind_eqv,[' ' ; ')'],[' ' ; '('],45)
   ind_column=gauss2sci_find_simple(stati,i,ind_length,':',ind_column,35)
   ind_startcond=gauss2sci_find_keywd(stati,i,ind_length,['if '],ind_startcond,[' '],[ ],11)
   ind_startcond=gauss2sci_find_keywd(stati,i,ind_length,['while '],ind_startcond,[' '],[ ],11)
   ind_startcond=gauss2sci_find_keywd(stati,i,ind_length,['until '],ind_startcond,[' '],[ ],11)
   ind_startcond=gauss2sci_find_keywd(stati,i,ind_length,['elseif '],ind_startcond,[' '],[ ],11)
   ind_print=gauss2sci_find_keywd(stati,i,ind_length,'print',ind_print,[' '],[' '],0)
   ind_comma=gauss2sci_find_simple(stati,i,ind_length,',',ind_comma,11)
 
end
[junk,ind]=gsort(ind_startcond(1,:),'g','i')
ind_startcond=ind_startcond(:,ind)
 
[junk,ind]=gsort(ind_dotcond(1,:),'g','i')
ind_dotcond=ind_dotcond(:,ind)
 
for i=1:size(ind_bookkeep_transp,2)
   ind_transp(:,ind_transp(1,:) == ind_bookkeep_transp(1,i))=[]
end
 
for i=1:size(ind_startilde,2)
   ind_star(:,ind_star(1,:) == ind_startilde(1,i))=[]
end
 
for i=1:size(ind_matmul,2)
   ind_star(:,ind_star(1,:) == ind_matmul(1,i)+1)=[]
end
 
for i=1:size(ind_kron,2)
   ind_matmul(:,ind_matmul(1,:) == ind_kron(1,i))=[]
end
 
for i=1:size(ind_matdiv,2)
   ind_slash(:,ind_slash(1,:) == ind_matdiv(1,i)+1)=[]
end
 
for i=1:size(ind_power,2)
   ind_hat(:,ind_hat(1,:) == ind_power(1,i))=[]
end
 
for i=1:size(ind_supeq,2)
   ind_sup(:,ind_sup(1,:) == ind_supeq(1,i))=[]
end
 
for i=1:size(ind_infeq,2)
   ind_inf(:,ind_inf(1,:) == ind_infeq(1,i))=[]
end
 
for i=1:size(ind_dotnot,2)
   ind_inf(:,ind_not(1,:) == ind_dotnot(1,i))=[]
end
 
for i=1:size(ind_dotand,2)
   ind_inf(:,ind_and(1,:) == ind_dotand(1,i))=[]
end
 
for i=1:size(ind_dotor,2)
   ind_inf(:,ind_or(1,:) == ind_dotor(1,i))=[]
end
 
for i=1:size(ind_dotxor,2)
   ind_inf(:,ind_xor(1,:) == ind_dotxor(1,i))=[]
end
 
for i=1:size(ind_doteqv,2)
   ind_inf(:,ind_eqv(1,:) == ind_doteqv(1,i))=[]
end
 
for i=1:size(ind_diff,2)
   ind_tilde(:,ind_tilde(1,:) == ind_diff(1,i))=[]
end
 
for i=1:size(ind_sup,2)
   ind_tilde(:,ind_supeq(1,:) == ind_sup(1,i))=[]
end
 
for i=1:size(ind_inf,2)
   ind_tilde(:,ind_infeq(1,:) == ind_inf(1,i))=[]
end
 
for i=size(ind_minus,2):-1:1
   if ind_minus(1,i) == 1 then
      ind_unary=[ind_minus(:,i) ind_unary]
      ind_minus(:,i)=[]
   else
      stat_start=stripblanks(part(strcat(statement,' '),1:ind_minus(1,i)-1))
      length_start=length(stat_start)
      char_before_minus=part(stat_start,length_start)
      char_3before_minus=part(stat_start,max(1,length_start-2):length_start)
      char_4before_minus=part(stat_start,max(1,length_start-3):length_start)
      if or(char_before_minus == [ '[' ; '*' ; '~' ; ',' ; ';' ; '/' ;'+' ; ...
          '=' ; '<' ; '>' ; '.' ; ':' ; '(' ; '%' ; '^']) then
         ind_unary=[ind_minus(:,i) ind_unary]
         ind_minus(:,i)=[]
      end
      if or(char_3before_minus == ['.le';'.lt';'.eq';'ne';'gt';'ge';...
         '.or';' or']) then
         ind_unary=[ind_minus(:,i) ind_unary]
         ind_minus(:,i)=[]
      end
      if or(char_4before_minus == ['.not';'.and';' not';' and';'.xor';' xor';...
         '.eqv';' eqv']) then
         ind_unary=[ind_minus(:,i) ind_unary]
         ind_minus(:,i)=[]
      end
   end
end
 
op=tlist(['op';'bookkeep_transp';...
'transp';'fact';'power';'hat';'unary';'star';'matmul';'kron';'startilde';'slash';...
'matdiv';'percent';'plus';'minus';'tilde';'pipe';'dotcond';...
'dotnot';'dotand';'dotor';'dotxor';'doteqv';...
'ne';'lt';'le';'doubleq';'gt';'ge';'not';'and';...
'or';'xor';'eqv';'column';'equal';'startcond';'print';'comma';...
'fuspar';'fusbrack';'all'],...
ind_bookkeep_transp,ind_transp,ind_fact,ind_power,ind_hat,...
ind_unary,ind_star,ind_matmul,ind_kron,ind_startilde,ind_slash,...
ind_matdiv,ind_percent,ind_plus,ind_minus,ind_tilde,ind_pipe,ind_dotcond,ind_dotnot,ind_dotand,...
ind_dotor,ind_dotxor,ind_doteqv,...
ind_diff,ind_inf,ind_infeq,ind_doubleq,ind_sup,ind_supeq,...
ind_not,ind_and,ind_or,ind_xor,ind_eqv,ind_column,ind_equal,...
ind_startcond,ind_print,ind_comma,ind_fuspar,ind_fusbrack)
 
ind_all=[]
ind_nonempty=[]
for i=2:length(op)-2
   ind_all=[ind_all op(i) ]
   if ~isempty(op(i)) then
      ind_nonempty=[ind_nonempty i]
   end
end
 
if ~isempty(ind_leftpar) then
   ind_all=[ind_all ind_leftpar ind_rightpar]
   ind_nonempty=[ind_nonempty length(op)-1]
 
end
if ~isempty(ind_leftbrack) then
   ind_all=[ind_all ind_leftbrack ind_rightbrack]
   ind_nonempty=[ind_nonempty length(op)]
 
end
 
 
[junk,ind]=gsort(ind_all(1,:),'g','i')
ind_all=ind_all(:,ind)
op('all')=ind_all
if ~isempty(ind_all) then
   ind_nonempty=[ind_nonempty length(op)]
end
 
endfunction
