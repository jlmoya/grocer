function resout=analyse_eq(equation)
 
// PURPOSE: breaks down an equation into elementary bricks
// ------------------------------------------------------------
// INPUT:
// * equation = a string, the text of an equation
// ------------------------------------------------------------
// OUTPUT:
// * resout = a tlist, whose type is equation, with as 2nd
//   argument the type of the operation, which can be:
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
// Copyright: Eric Dubois 2012-2013
// http://grocer.toolbox.free.fr/grocer.html
 
global grocer_variables GROCERDIR;
grocer_variables=[]
 
// replace wrong representations of operators by their true one
// (to allow the function to recognize operators and not to consider
// them erroneously as names)
equation=strsubst(equation,ascii([226 128 147]),ascii(45))
// change +- into - and ++ or -- into + to avoid useless double operators
length_eq=0
while length(equation) ~= length_eq then
   length_eq=length(equation)
   equation=strsubst(equation,'+-','-')
   equation=strsubst(equation,'++','+')
   equation=strsubst(equation,'--','+')
end
 
load(GROCERDIR+'\param\symb_listfunc.dat')
[op,op_fuspar]=Scilab_ind_operators(equation);
 
resout=analyse_eq1(equation,op('all'),op_fuspar)
 
endfunction
