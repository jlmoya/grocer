function resout=simplify_eq(reseq)
 
// PURPOSE: provides some simplifications on an 'equation'
// such as the final result of opertaions on scalars, the
// elimination of zeros,...
// ------------------------------------------------------------
// INPUT:
// * reseq = an 'equation' tlist, the result of the breaking
//  down of an equation into elementary bricks
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
//   - 'unknown'
//     in that case there is the following field:
//     . 'name unknown': a string, the name of the found
//        unknown object
// ------------------------------------------------------------
// Copyright: Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
 
resout=reseq
select reseq('type')
case 'unary' then
   res_rhs=simplify_eq(reseq('rhs'))
   if res_rhs('type') == 'scalar' then
      if res_rhs('val') == '0' then
         resout=res_rhs
      else
         resout=tlist(['equation';'type';'operator';'rhs'],...
                 'unary',reseq('operator'),res_rhs)
      end
 
   elseif res_rhs('type') == 'parentheses' then
      res_rhs_exp=res_rhs('exp')
      if res_rhs_exp('type') == 'unary' then
         resout=res_rhs_exp('rhs')
      else
         resout=tlist(['equation';'type';'operator';'rhs'],...
                 'unary',reseq('operator'),res_rhs)
      end
 
   else
         resout=tlist(['equation';'type';'operator';'rhs'],...
                 'unary',reseq('operator'),res_rhs)
   end
 
case 'parentheses' then
   res_exp=simplify_eq(reseq('exp'))
   select res_exp('type')
   case 'scalar' then
      resout=res_exp
   case 'parentheses'
      resout=tlist(['equation';'type';'exp'],'parentheses',res_exp('exp'))
   case 'variable'
      resout=res_exp
   case 'unknown'
      resout=res_exp
   else
      resout=tlist(['equation';'type';'exp'],'parentheses',res_exp)
   end
 
case 'operation' then
   op=reseq('operator')
 
   select op
   case '+' then
      resr=simplify_eq(reseq('rhs'))
      resl=simplify_eq(reseq('lhs'))
      if resr('type') == 'scalar' then
         if resr('val') == '0' then
            resout=resl
         elseif resl('type') == 'scalar' then
            resout=tlist(['equation';'type';'val'],'scalar',string(evstr(resl('val')+op+resr('val'))))
         else
            resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
         end
 
      elseif resl('type') == 'scalar' & resl(3) == '0' then
         resout=resr
 
      else
         resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
      end
 
   case '-' then
      resr=simplify_eq(reseq('rhs'))
      resl=simplify_eq(reseq('lhs'))
      if resr('type') == 'scalar' then
         if resr('val') == '0' then
            resout=resl
         elseif resl('type') == 'scalar' then
            resout=tlist(['equation';'type';'val'],'scalar',string(evstr(resl('val')+op+resr('val'))))
         else
            resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
         end
 
      elseif resr('type') == 'parentheses' then
         resr_betweenpar=resr('exp')
         if resr_betweenpar('type') == 'unary' then
            resout=simplify_eq(tlist(['equation';'type';'lhs';'operator';'rhs'],'operation',resl,'+',resr_betweenpar('rhs')))
         else
            resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
         end
 
      else
         resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
      end
 
   case '*' then
      resr=simplify_eq(reseq('rhs'))
      if resr('type') == 'scalar' then
         if resr('val') == '0' then
            resout=resr
         else
            resl=simplify_eq(reseq('lhs'))
            if resr('val') == '1' then
               resout=resl
            elseif resl('type') == 'scalar' then
               resout=tlist(['equation';'type';'val'],'scalar',string(evstr(resl('val')+op+resr('val'))))
            else
               resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
            end
         end
 
      else
         resl=simplify_eq(reseq('lhs'))
         if resl('type') == 'scalar' then
            if resl('val') == '0' then
               resout=resl
            elseif resl('val') == '1' then
               resout=resr
            else
               resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
            end
         else
            resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
         end
      end
 
   case ' .*' then
      resr=simplify_eq(reseq('rhs'))
      if resr('type') == 'scalar' then
         if resr('val') == '0' then
            resout=resr
         else
            resl=simplify_eq(reseq('lhs'))
            if resl('type') == 'scalar' & resl('val') == '0' then
               resout=resl
            elseif resl('type') == 'scalar' then
               resout=tlist(['equation';'type';'val'],'scalar',string(evstr(resl('val')+'*'+resr('val'))))
            else
               resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
            end
         end
 
      else
         resl=simplify_eq(reseq('lhs'))
         if resl('type') == 'scalar' then
            if resl('val') == '0' then
               resout=resl
            elseif resl('val') == '1' then
               resout=resr
            else
               resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
            end
         else
            resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
         end
      end
 
   case '/' then
      resl=simplify_eq(reseq('lhs'))
      if resl('type') == 'scalar' then
         if resl('type') == '0' then
            resout=resl
         else
            resr=simplify_eq(reseq('rhs'))
            if resr('type') == 'scalar' then
                resout=tlist(['equation';'type';'val'],'scalar',string(evstr(resl('val')+'/'+resr('val'))))
            else
               resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                             'operation',resl,op,resr)
            end
         end
 
      else
         resr=simplify_eq(reseq('rhs'))
         if resr('type') == 'scalar' then
            if resr('val') == '1' then
               resout=resl
            else
               resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
            end
         else
            resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                 'operation',resl,op,resr)
         end
      end
 
   case ' ./' then
      resl=simplify_eq(reseq('lhs'))
      if resl('type') == 'scalar' then
         if resl('val') == '0' then
            resout=resl
         else
            resr=simplify_eq(reseq('rhs'))
            if resr('type') == 'scalar' then
                resout=tlist(['equation';'type';'val'],'scalar',string(evstr(resl('val')+'/'+resr('val'))))
            else
               resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                 'operation',resl,op,resr)
            end
         end
      else
         resr=simplify_eq(reseq('rhs'))
         if resr('type') == 'scalar' then
            if resr('val') == '1' then
               resout=resl
            else
               resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                    'operation',resl,op,resr)
            end
         else
            resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                 'operation',resl,op,resr)
         end
      end
 
   case '^' then
      resl=simplify_eq(reseq('lhs'))
      if resl('type') == 'scalar' then
         if resl('val') == '0' then
            resout=resl
         elseif resr('type') == 'scalar' & resr(3) == '1' then
              resout=resl
         else
            resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                   'operation',resl,op,resr)
         end
      else
         resr=simplify_eq(reseq('rhs'))
         if resr('type') == 'scalar' & resr(3) == '1' then
              resout=resl
         else
            resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                   'operation',resl,op,resr)
         end
      end
 
   case ' .^' then
      resl=simplify_eq(reseq('lhs'))
      if resl('type') == 'scalar' then
         if resl('val') == '0' then
            resout=resl
         elseif resr('type') == 'scalar' & resr(3) == '1' then
              resout=resl
         else
            resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                   'operation',resl,op,resr)
         end
      else
         resr=simplify_eq(reseq('rhs'))
         if resr('type') == 'scalar' & resr(3) == '1' then
              resout=resl
         else
            resout=tlist(['equation';'type';'lhs';'operator';'rhs'],...
                   'operation',resl,op,resr)
         end
      end
 
   else
      resl=simplify_eq(reseq('lhs'))
      resr=simplify_eq(reseq('rhs'))
 
   end
 
case 'function' then
   res_func=simplify_eq(reseq('input'))
   if res_func('type') == 'parentheses' then
      res_func=simplify_eq(res_func('exp'))
   end
   if res_func('type') == 'scalar' then
      resout=tlist(['equation';'type';'val'],'scalar',string(evstr(reseq('name func')+'('+res_func('val')+')')))
   else
      resout=tlist(['equation';'type';'name func';'input'],'function',reseq('name func'),res_func)
   end
 
end
 
 
endfunction
