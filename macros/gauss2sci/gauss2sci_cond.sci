function [statement,ind_length,op,ind_statements]=gauss2sci_cond(statement,type_statement,ind_length,op,ind_statements)
 
// PURPOSE: replace Gauss simple conditions
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
// * op = a tlist with each field corresponding to an operator
//   op(i) = a (4 x p) matrix:
//   - first line: the positions of the operator
//   - second line: the statement number where the operator
//     appears
//   - third line: the position of the operator end
//   - fourth line: the precedence of the operator, as
//     indicated in the table of gauss manual (chapter 11-23
//     for gauss 10 version)
// ------------------------------------------------------------
// OUTPUT:
// * statement = the same statement but with Scilab
//   definitions for conditionals
// * op = the transformed operators tlist
// * ind_length = the transformed vector of cumulated lengths
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
//op=gauss2sci_ind_operators(statement,type_statement,ind_length)
ind_all=op('all')
ind_fuspar=op('fuspar')
ind_leftpar=ind_fuspar(:,ind_fuspar(3,:) == 1)
ind_rightpar=ind_fuspar(:,ind_fuspar(3,:) == -1)
ind_ne=find(op(1) == 'ne')
 
ind_cond=op(ind_ne)
for i=ind_ne+1:ind_ne+5
    ind_cond=[ind_cond op(i)]
end
 
[junk,indexes]=gsort([ind_cond(1,:)],'g','i')
ind_cond=ind_cond(:,indexes)
 
for j=1:size(statement,'*')
 
   if ~isempty(statement(j)) then
 
      statement(j)=strsubst_trueobj(statement(j),'or','| ',[' ';'('],[' ';')'],%f,%t)
      statement(j)=strsubst_trueobj(statement(j),'and',' & ',[' ';'('],[' ';')'],%f,%t)
   end
end
 
for i=1:size(ind_cond,2)
 
   ind_i=ind_cond(1,i)
   ind_start=find_start(ind_leftpar,ind_rightpar,ind_all,56,ind_i)
 
   statement(ind_start(2))=part(statement(ind_start(2)),1:ind_start(1)-1-ind_length(ind_start(2)))+' and('+...
                           part(statement(ind_start(2)),ind_start(1)-ind_length(ind_start(2)):ind_length(ind_start(2)+1))
   ind_length(ind_start(2)+1:$)=ind_length(ind_start(2)+1:$)+5
 
   op=shift_op(op,ind_nonempty,ind_start(1),5)
   ind_all=op('all')
   ind_leftpar(1,ind_leftpar(1,:)>ind_start(1))=ind_leftpar(1,ind_leftpar(1,:)>ind_start(1))+5
   ind_rightpar(1,ind_rightpar(1,:)>ind_start(1))=ind_rightpar(1,ind_rightpar(1,:)>ind_start(1))+5
   ind_cond(1,ind_cond(1,:)>=ind_start(1))=ind_cond(1,ind_cond(1,:)>=ind_start(1))+5
   ind_cond(3,ind_cond(1,:)>=ind_start(1))=ind_cond(3,ind_cond(1,:)>=ind_start(1))+5
 
   ind_end=find_end(ind_leftpar,ind_rightpar,ind_all,56,ind_cond(3,i),ind_length($)-1)   // now enclose the found matrix between brackets
   blank=%t
   while blank then
      if ind_end(1) == 0 then
         blank=%F
      elseif part(statement(ind_end(2)),ind_end(1)) ~= ' ' then
         blank=%F
      else
         ind_end(1)=ind_end(1)-1
      end
   end
 
   statement(ind_end(2))=part(statement(ind_end(2)),1:ind_end(1)-ind_length(ind_end(2)))+')'+...
                         part(statement(ind_end(2)),ind_end(1)-ind_length(ind_end(2))+1:ind_length(ind_end(2)+1))
   ind_length(ind_end(2)+1:$)=ind_length(ind_end(2)+1:$)+1
 
   op=shift_op(op,ind_nonempty,ind_end(1),1)
   ind_all=op('all')
   ind_leftpar(1,ind_leftpar(1,:)>ind_end(1))=ind_leftpar(1,ind_leftpar(1,:)>ind_end(1))+1
   ind_rightpar(1,ind_rightpar(1,:)>=ind_end(1))=ind_rightpar(1,ind_rightpar(1,:)>=ind_end(1))+1
   ind_cond(1,ind_cond(1,:)>ind_end(1))=ind_cond(1,ind_cond(1,:)>ind_end(1))+1
   ind_cond(3,ind_cond(1,:)>ind_end(1))=ind_cond(3,ind_cond(1,:)>ind_end(1))+1
 
end
 
ind_doteqv=op('doteqv')
for i=size(ind_doteqv,2):-1:1
   ind_i=ind_doteqv(:,i)
   ind_start=find_start(ind_leftpar,ind_rightpar,ind_all,60,ind_i(1))
   ind_end=find_end(ind_leftpar,ind_rightpar,ind_all,60,ind_doteqv(3,i),ind_length($)-1)   // now enclose the found matrix between brackets
   statement(ind_end(2))=part(statement(ind_end(2)),1:ind_end(1)-ind_length(ind_end(2)))+')'+...
                         part(statement(ind_end(2)),ind_end(1)-ind_length(ind_end(2))+1:ind_length(ind_end(2)+1))
   statement(ind_i(2))=part(statement(ind_i(2)),1:ind_i(1)-ind_length(ind_i(2))-1)+','+...
                         part(statement(ind_i(2)),ind_i(1)-ind_length(ind_i(2))+4:ind_length(ind_i(2)+1))
   statement(ind_start(2))=part(statement(ind_start(2)),1:ind_start(1)-ind_length(ind_start(2))-1)+'doteqv('+...
                         part(statement(ind_start(2)),ind_start(1)-ind_length(ind_start(2))+1:ind_length(ind_start(2)+1))
   op=shift_op(op,ind_nonempty,ind_end(1),1)
   op=shift_op(op,ind_nonempty,ind_i(1),-3)
   op=shift_op(op,ind_nonempty,ind_start(1),7)
 
end
 
ind_dotxor=op('dotxor')
for i=size(ind_dotxor,2):-1:1
   ind_i=ind_dotxor(:,i)
   ind_start=find_start(ind_leftpar,ind_rightpar,ind_all,60,ind_i(1))
   ind_end=find_end(ind_leftpar,ind_rightpar,ind_all,60,ind_dotxor(3,i),ind_length($)-1)   // now enclose the found matrix between brackets
   statement(ind_end(2))=part(statement(ind_end(2)),1:ind_end(1)-ind_length(ind_end(2)))+')'+...
                         part(statement(ind_end(2)),ind_end(1)-ind_length(ind_end(2))+1:ind_length(ind_end(2)+1))
   statement(ind_i(2))=part(statement(ind_i(2)),1:ind_i(1)-ind_length(ind_i(2))-1)+','+...
                         part(statement(ind_i(2)),ind_i(1)-ind_length(ind_i(2))+4:ind_length(ind_i(2)+1))
   statement(ind_start(2))=part(statement(ind_start(2)),1:ind_start(1)-ind_length(ind_start(2))-1)+'dotxor('+...
                         part(statement(ind_start(2)),ind_start(1)-ind_length(ind_start(2))+1:ind_length(ind_start(2)+1))
   op=shift_op(op,ind_nonempty,ind_end(1),1)
   op=shift_op(op,ind_nonempty,ind_i(1),-3)
   op=shift_op(op,ind_nonempty,ind_start(1),7)
 
end
 
for i=size(op('dotcond'),2):-1:1
   ind_dotcond=op('dotcond')
   ind_i=ind_dotcond(:,i)
   ind_start=find_start(ind_leftpar,ind_rightpar,ind_all,55,ind_i(1))
   ind_end=find_end(ind_leftpar,ind_rightpar,ind_all,55,ind_dotcond(3,i),ind_length($)-1)   // now enclose the found matrix between brackets
   cond_i=part(statement(ind_i(2)),ind_i(1)+[1:2]-ind_length(ind_end(2)))
   stat_end=statement(ind_end(2))
   statement(ind_end(2))=part(stat_end,1:ind_end(1)-ind_length(ind_end(2)))+')'+...
                         part(stat_end,ind_end(1)-ind_length(ind_end(2))+1:length(stat_end))
   stat_i=statement(ind_i(2))
   statement(ind_i(2))=part(stat_i,1:ind_i(1)-ind_length(ind_i(2))-1)+','+...
                         part(stat_i,ind_i(1)-ind_length(ind_i(2))+3:length(stat_i))
   stat_start=statement(ind_start(2))
   statement(ind_start(2))=part(stat_start,1:ind_start(1)-ind_length(ind_start(2))-1)+...
                          cond_i+'_gauss('+...
                          part(stat_start,ind_start(1)-ind_length(ind_start(2)):length(stat_start))
   op=shift_op(op,ind_nonempty,ind_end(1)+1,1)
   op=shift_op(op,ind_nonempty,ind_i(1)+1,-3)
   op=shift_op(op,ind_nonempty,ind_start(1)+1,9)
end
 
if ~isempty(ind_cond) | ~isempty(ind_doteqv) | ~isempty(ind_dotxor) | ...
    ~isempty(op('dotcond')) then
    ind_statements(ind_statements == i_stat)=[]
end
 
endfunction
