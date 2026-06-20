function [firstpart,secondpart]=cut_express(namey)
 
// PURPOSE: cut an expression in the smmallest complete part
// starting from the left and the rest of the expression
// ------------------------------------------------------------
// INPUT:
// * namey = a string
// ------------------------------------------------------------
// OUTPUT:
// * firsrtpart = the smallest complete part starting from the
//   left
// * secondpart = the rest of the expression
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
 
ind_leftpar=strindex(namey,'(')
length_namey=length(namey)
 
if part(namey,1) == '(' then
   // find the corresponding right parenthesis and transfer
   // the expression to the rhs of the equation
   [firstpart,ind_strout]=find_end_expr(namey,ind_leftpar)
   secondpart=part(namey,ind_strout(2)+1:length_namey)
 
else
// find what ends the expresion
   ind_plus=strindex(namey,'+')
   ind_minus=strindex(namey,'-')
   ind_mult=strindex(namey,'*')
   ind_div=strindex(namey,'/')
   ind_exp=strindex(namey,'^')
   ind_allsimple=[ind_plus ind_minus ind_mult ind_div]
   ind_minall=min(ind_allsimple)
 
   if isempty(ind_allsimple) then
      firstpart=namey
      secondpart=emptystr()
 
   elseif isempty(ind_leftpar) then
      firstpart=part(namey,1:ind_minall-1)
      secondpart=part(namey,ind_minall:length_namey)
 
   elseif isempty(ind_exp) then
      if ind_leftpar(1) < ind_minall then
         [firstpart,ind_strout]=find_end_expr(namey,ind_leftpar)
         secondpart=part(namey,ind_strout(2)+1:length_namey)
 
      else
         firstpart=part(namey,1:ind_minall-1)
         secondpart=part(namey,ind_minall:length_namey)
      end
 
   elseif ind_leftpar(1) < min([ind_minall ind_exp(1)]) then
      [firstpart,ind_strout]=find_end_expr(namey,ind_leftpar)
      secondpart=part(namey,ind_strout(2)+1:length_namey)
 
   elseif ind_exp(1) > ind_minall then
      firstpart=part(namey,2:ind_minall-1)
      secondpart=part(namey,ind_minall:length_namey)
 
   elseif part(namey,ind_exp(1)+1) == '(' then
      [firstpart,ind_strout]=find_end_expr(namey,ind_leftpar)
      secondpart=part(namey,ind_strout+1:length_namey)
 
   else
      firspart=part(namey,1:ind_minall-1)
      secondpart=part(namey,ind_minall:length_namey)
   end
end
 
endfunction
