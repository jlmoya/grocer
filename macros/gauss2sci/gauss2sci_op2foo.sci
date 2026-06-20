function [statement,op,ind_length]=gauss2sci_op2foo(statement,op,ind_length,op_i,foo,preced,length_opi)
 
// PURPOSE: in a gauss translation, transform an operator (such
// as /, .*, ./) into a function
// ------------------------------------------------------------
// INPUT:
// * statement = a gauss statement
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
// * ind_length = a (1 x (K+1)) vector, starting with 0 and
//   then indicating the cumulated length of the statement
//   components
// * op_i = a string, the name of the operator in the operators
//   tlist
// * foo = the name of the function, opening parenthesis
//   included (e.g. matdiv( for ./)
// * preced = an integer, the precedence of the operator
// * length_opi = an integer, the length of the operator
// ------------------------------------------------------------
// OUTPUT:
// * statement = the transformed gauss statement
// * op = the transformed operators tlist
// * ind_length = the transformed vector of cumulated lengths
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
 
ind_op=op(op_i)
ind_all=op('all')
decal1=length(foo)
decal2=1-length_opi
 
for i=size(ind_op,2):-1:1
   ind_i=ind_op(:,i)
   ind_op(:,$)=[]
   op(op_i)=ind_op
   ind_fuspar=op('fuspar')
   ind_leftpar=ind_fuspar(:,ind_fuspar(3,:) == 1)
   ind_rightpar=ind_fuspar(:,ind_fuspar(3,:) == -1)
   [ind_start,ind_end]=find_limits(statement,ind_leftpar,ind_rightpar,ind_fuspar,ind_all,preced,ind_i,ind_length)
   statement(ind_end(2))=part(statement(ind_end(2)),1:ind_end(1)-ind_length(ind_end(2)))+')'+...
                     part(statement(ind_end(2)),ind_end(1)-ind_length(ind_end(2))+1:length(statement(ind_end(2))))
   //add comma to separate arguments in the function
   statement(ind_i(2))=part(statement(ind_i(2)),1:ind_i(1)-ind_length(ind_i(2))-1)+','+...
                   part(statement(ind_i(2)),ind_i(1)-ind_length(ind_i(2))+length_opi:length(statement(ind_i(2))))
   //add name of the function (parenthesis included) before first argument
   statement(ind_start(2))=part(statement(ind_start(2)),1:ind_start(1)-ind_length(ind_start(2))-1)+foo+...
                       part(statement(ind_start(2)),ind_start(1)-ind_length(ind_start(2)):length(statement(ind_start(2))))
   // shift the operator indexes by the added amounts
   op=shift_op(op,ind_nonempty,ind_end(1),1)
   ind_length(ind_end(2)+1:$)=ind_length(ind_end(2)+1:$)+1
   op=shift_op(op,ind_nonempty,ind_i(1)+1,decal2)
   ind_length(ind_i(2)+1:$)=ind_length(ind_i(2)+1:$)+decal2
   op=shift_op(op,ind_nonempty,ind_start(1),decal1)
   ind_length(ind_start(2)+1:$)=ind_length(ind_start(2)+1:$)+decal1
 
   // add the indexes of the new parentheses and change accordingly the cumulated sign of the
   // existing ones
   ind_fuspar=op('fuspar')
   ind_fuspar_1=ind_fuspar(:,ind_fuspar(1,:)<ind_start(1))
   ind_fuspar_2=[ind_start(1)+decal1-1 ; ind_start(2) ; 1 ; ind_fuspar_1(4,$)+1 ]
   ind_fuspar_3=ind_fuspar(:,ind_fuspar(1,:)>=ind_start(1)+decal1 & ind_fuspar(1,:)<=ind_end(1)+decal1+decal2+1)
   if ~isempty(ind_fuspar_3) then
      ind_fuspar_3(4,:)=ind_fuspar_3(4,:)+1
   end
   ind_fusparn=[ind_fuspar_1 ind_fuspar_2 ind_fuspar_3]
   ind_fuspar_4=[ind_end(1)+decal1+decal2+1 ; ind_end(2) ; -1 ;ind_fusparn(4,$)-1]
   ind_fuspar_5=ind_fuspar(:,ind_fuspar(1,:)>=ind_end(1)+decal1+decal2+2)
 
   ind_fuspar=[ind_fusparn ind_fuspar_4 ind_fuspar_5]
   op('fuspar')=ind_fuspar
 
   // add the new comma to the list of operators
   ind_comma=op('comma')
   ind_comma=[ind_comma(:,ind_comma(1,:)<ind_i(1)) [ind_i(1)+decal1 ; ind_i(2);ind_i(1)+decal1+1;11] ind_comma(:,ind_comma(1,:)>ind_i(1))]
   ind_nonempty=[ind_nonempty(ind_nonempty<40) 40 ind_nonempty(ind_nonempty>40)]
   op('comma')=ind_comma
 
   ind_all=op('all')
   ind_all(:,ind_all(1,:)==ind_i(1)+decal1)=[ind_i(1)+decal1;ind_i(2);ind_i(1)+decal1+1;11]
   ind_all=[ind_all(:,ind_all(1,:)<ind_start(1)) ...
               [ind_start(1)+decal1-1 ; ind_start(2) ; ind_start(1)+decal1 ; 11] ...
               ind_all(:,ind_all(1,:)>ind_start(1) & ind_all(1,:)<=ind_end(1)+decal1) ...
                [ind_end(1)+decal1 ; ind_end(2) ; ind_end(1)+decal1+11 ; 11] ind_all(:,ind_all(1,:)>ind_end(1)+decal1)]
   op('all')=ind_all
 
   ind_op=op(op_i)
 
end
 
endfunction
