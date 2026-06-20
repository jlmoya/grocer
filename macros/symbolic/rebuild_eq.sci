function equation=rebuild_eq(reseq)
 
// PURPOSE: from an 'equation' tlist, recover the corresponding
// equation
// ------------------------------------------------------------
// INPUT:
// * reseq = an 'equation' tlist
// ------------------------------------------------------------
// OUTPUT:
// * equation = a string, the text of an equation
// ------------------------------------------------------------
// Copyright: Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
if isempty(reseq) then
   equation=emptystr()
 
else
   if typeof(reseq) ~= 'equation' then
      disp(reseq)
      error(typeof(reseq)+' is not an equation type')
   end
 
   select reseq('type')
 
   case 'operation'
      lhs=reseq('lhs')
      rhs=reseq('rhs')
 
      if lhs(1)(3) == 'val' & rhs(1)(3) == 'val' then
         execstr('equation='+lhs(3)+reseq('operator')+rhs(3))
         equation=string(equation)
      else
         equation=rebuild_eq(lhs)+reseq('operator')+rebuild_eq(rhs)
      end
 
   case 'scalar' then
      equation=reseq('val')
 
   case 'unary' then
      equation=reseq('operator')+rebuild_eq(reseq('rhs'))
 
   case 'predefined' then
      equation=reseq('name predefined')
 
   case 'variable' then
      equation=reseq('name variable')
 
   case 'function' then
      equation=reseq('name func')+'('+rebuild_eq(reseq('input'))+')'
 
   case 'parentheses' then
      equation='('+rebuild_eq(reseq('exp'))+')'
 
   case 'power' then
      equation=rebuild_eq(reseq('exp'))+'^'+reseq('power')
   end
 
end
 
endfunction
