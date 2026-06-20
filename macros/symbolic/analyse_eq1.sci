function resout=analyse_eq1(equation,op_all,op_fuspar)
 
// PURPOSE: breaks down an equation into elementary bricks
// ------------------------------------------------------------
// INPUT:
// * equation = a string, the text of an equation
// * op_all = a (3 x p) matrix giving informations on the
//   operators in the text:
//   - first line: the positions of the operator
//   - second line: the length of the operator
//   - third line: the precedence of the operator, as
//     estimated by myself
// * op_fuspar = a (4 x p) matrix giving informations on the
//   parenthseses in the text:
//   - first line:
// ------------------------------------------------------------
// OUTPUT:
// * resout = a tlist, whose type is equation, with as 2nd
//   argument the type of the opertaion, which can be:
//   - 'operation' (such as '+', '*', '.*' , ...);
//     in that case there are the following fields:
//     . 'lhs': an 'equation' tlist relative to the left hand
//        side of the operation
//     . 'operator': the operator (!)
//     . 'rhs': an 'equation' tlist relative to the right hand
//        side of the operation
//   - 'unary' (when a unary '-', as opposed to the operator,
//     has been found
//     in that case there is the following field:
//     . 'rhs': the equation' tlist relative to the expression
//       after the '-'
//   - 'parentheses'
//     in that case there is the following field:
//     . 'exp': the equation' tlist relative to expression
//       between the parentheses
//   - 'function'
//     in that case there is the following field:
//     . 'input': the 'equation' tlist relative to the input of
//       the function
//   - 'scalar'
//     in that case there is the following field:
//     . 'val': a string, the value of the number that
//       represents the equation
//   - 'variable'
//     in that case there is the following field:
//     . 'name vari': a string, the name of the found variable,
//        assessed as such if it is a matrix or a ts
//   - unknown'
//     in that case there is the following field:
//     . 'variable': a string, the name of the found
//        grocer_unknown object
// ------------------------------------------------------------
// NOTES:
// * this is a recursive function; there is an higher level
//   function analyse_eq that first performs the inputs op_all
//   and op_fuspar on a user equation
// * there is global variable "grocer_unknown", whic is set to %t
//   if the euqation is found to contain an grocer_unknown object:
//   this can be used, as in nls, to check if you have to use
//   to a numercial derivative instead of an analytical one
// ------------------------------------------------------------
// Copyright: Eric Dubois 2011-2015
// http://grocer.toolbox.free.fr/grocer.html
 
global grocer_variables ;
 
if isempty(equation) then
   resout=[]
 
elseif isempty(op_all) & isempty(op_fuspar) then
  // there is no operator nor parenthesis: this the name of a variable or a function
   equation=strsubst(equation,' ','')
   if isnum(equation) & equation ~= 'i' then
      resout=tlist(['equation';'type';'val'],'scalar',equation)
 
   elseif or(grocer_listfunctions == equation) then
      resout=tlist(['equation';'type';'name func'],'function',equation)
 
   else
      resout=tlist(['equation';'type';'name variable'],'variable',equation)
      grocer_variables=[grocer_variables ; equation]
 
   end
 
else
   op_partial=op_all
 
   if isempty(op_fuspar) then
      [val_prevalentop,ind_prevalentop]=min(op_partial(3,:))
      ind_prevalentop=find(op_partial(3,:) == val_prevalentop)
      ind_op=op_partial(:,ind_prevalentop($))
      operator=part(equation,ind_op(1)+[0:ind_op(2)-1])
 
      equation2=part(equation,ind_op(1)+ind_op(2):length(equation))
      op2=op_all(:,op_all(1,:) >= ind_op(1)+ind_op(2))
      if ~isempty(op2) then
         op2(1,:)=op2(1,:)-ind_op(1)-ind_op(2)+1
      end
      op_fuspar2=op_fuspar(:,op_fuspar(1,:) >= ind_op(1)+ind_op(2))
      if ~isempty(op_fuspar2) then
         op_fuspar2(1,:)=op_fuspar2(1,:)-ind_op(1)-ind_op(2)+1
      end
 
      equation1=part(equation,1:ind_op(1)-1)
      op_fuspar1=op_fuspar(:,op_fuspar(1,:) < ind_op(1))
      op1=op_all(:,op_all(1,:) < ind_op(1))
 
      if isempty(equation1) then
         resout=tlist(['equation';'type';'operator';'rhs'],...
                      'unary',operator,analyse_eq1(equation2,op2,op_fuspar2))
 
      else
         resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                      'operation',analyse_eq1(equation1,op1,op_fuspar1),...
                      ' '+operator,analyse_eq1(equation2,op2,op_fuspar2))
      end
 
   else
      // find the last closing parenthesis and the corresponding
      // opening one
      ind_parright=find(op_fuspar(3,:) == -1)
      par_level=op_fuspar(4,ind_parright($))
      ind_parright=op_fuspar(:,op_fuspar(4,:) == par_level & op_fuspar(3,:) == -1)
      ind_parrighteq=op_fuspar(1,$)
 
      ind_parleft=op_fuspar(:,op_fuspar(4,:) == par_level+1 & op_fuspar(3,:) == 1)
      ind_parlefteq=ind_parleft(1,$)
 
      for i=1:size(ind_parright,2)
         ind_parleftbef=ind_parleft(:,ind_parleft(1,:) < ind_parright(1,i))
         op_partial(:,op_partial(1,:) >= ind_parleftbef(1,$) & op_partial(1,:) <= ind_parright(1,i)) = []
      end
 
      if ~isempty(op_partial) then
          // an operator starts the last part of the equation
         val_prevalentop=min(op_partial(3,:))
         ind_prevalentop=find(op_partial(3,:) == val_prevalentop)
         ind_op=op_partial(:,ind_prevalentop($))
         operator=part(equation,ind_op(1)+[0:ind_op(2)-1])
 
         equation2=part(equation,ind_op(1)+ind_op(2):length(equation))
         op2=op_all(:,op_all(1,:) >= ind_op(1)+ind_op(2))
         if ~isempty(op2) then
            op2(1,:)=op2(1,:)-ind_op(1)-ind_op(2)+1
         end
         op_fuspar2=op_fuspar(:,op_fuspar(1,:) >= ind_op(1)+ind_op(2))
         if ~isempty(op_fuspar2) then
            op_fuspar2(1,:)=op_fuspar2(1,:)-ind_op(1)-ind_op(2)+1
         end
 
         equation1=part(equation,1:ind_op(1)-1)
         op_fuspar1=op_fuspar(:,op_fuspar(1,:) < ind_op(1))
         op1=op_all(:,op_all(1,:) < ind_op(1))
 
         if isempty(equation1) then
            if or(operator == ['-' ; ascii([226 128 147])]) then
               resout=tlist(['equation';'type';'operator';'rhs'],...
                         'unary','-',analyse_eq1(equation2,op2,op_fuspar2))
 
            elseif operator == '+' then
               resout=analyse_eq1(equation2,op2,op_fuspar2)
 
            else
               error('not a valid member of equation: '+operator+equation2)
            end
 
         else
            resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                      'operation',analyse_eq1(equation1,op1,op_fuspar1),...
                      operator,analyse_eq1(equation2,op2,op_fuspar2))
         end
 
      else
         // all operators encapsulated in parentheses
 
         start_exp=stripblanks(part(equation,1:ind_parlefteq-1))
         if isempty(start_exp) then
            equation1=part(equation,ind_parlefteq+1:ind_parrighteq-1)
            if ~isempty(op_all) then
               op_all(1,:)=op_all(1,:)-ind_parlefteq
            end
            op_fuspar1=op_fuspar(:,2:$-1)
            if ~isempty(op_fuspar1) then
                op_fuspar1(1,:)=op_fuspar1(1,:)-ind_parlefteq
            end
            resout=tlist(['equation';'type';'exp'],'parentheses',...
                   analyse_eq1(equation1,op_all,op_fuspar1))
 
         elseif or(start_exp == ['-';'+']) then
            equation1=part(equation,ind_parlefteq+1:ind_parrighteq-1)
            if ~isempty(op_all) then
               op_all(1,:)=op_all(1,:)-ind_parlefteq
            end
            op_fuspar1=op_fuspar(:,2:$-1)
            if ~isempty(op_fuspar1) then
                op_fuspar1(1,:)=op_fuspar1(1,:)-ind_parlefteq
            end
            resout=tlist(['equation';'type';'operator';'rhs'],...
                      'unary',start_exp,analyse_eq1(equation1,op_all,op_fuspar1))
 
         else
            // there is a name before the parentheses
            equation1=stripblanks(part(equation,1:ind_parlefteq-1))
            equation2=part(equation,ind_parlefteq+1:ind_parrighteq-1)
            if isnum(equation2) & equation2 ~= 'i' then
               resout=tlist(['equation';'type';'val'],'scalar',string(evstr(equation)))
 
            elseif or(grocer_listfunctions == equation1) then
               op_fuspar2=op_fuspar(:,2:$-1)
               if ~isempty(op_fuspar2) then
                  op_fuspar2(1,:)=op_fuspar2(1,:)-ind_parlefteq(1)
               end
               if ~isempty(op_all) then
                  op_all(1,:)=op_all(1,:)-ind_parlefteq(1)
               end
               resout=tlist(['equation';'type';'name func';'input'],'function',equation1,...
                         analyse_eq1(equation2,op_all,op_fuspar2))
 
            else
               resout=tlist(['equation';'type';'name variable'],'variable',equation)
               grocer_variables=[grocer_variables ; equation]
 
            end
         end
      end
   end
 
end
 
endfunction
