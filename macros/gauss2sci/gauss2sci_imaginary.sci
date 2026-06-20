function [statk]=gauss2sci_imaginary(statk)
 
// PURPOSE: susbtitue Gauss imaginary numer i into Scilab
// imaginary number %i
// ------------------------------------------------------------
// INPUT:
// * statk = a statement element
// ------------------------------------------------------------
// OUTPUT:
// * statk = the transformed statement
// ------------------------------------------------------------
// NOTE: this comes at the end and neither op nor ind_length
// are therefore updated
// ------------------------------------------------------------
// Copyright: Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
for j=0:9
   maybe_i=strindex(statk,string(j)+'i')
   for k=size(maybe_i,2):-1:1
      imaginary=%f
      ind_start=maybe_i(k)
      start=(ind_start==1)
      while ~start then
 
         ind_start=ind_start-1
         start=%t
         if ind_start == 1 then
            if or(part(statk,1) == [string(0:9) '.' ' '])  then
               imaginary=%t
            end
 
         elseif or(part(statk,ind_start-1:ind_start) == ['e+' ; 'e-']) then
            start=%t
            imaginary=%t
 
         elseif or(part(statk,ind_start) == [string(0:9) '.'])  then
            ind_start=ind_start-1
 
         elseif or(ind_start == op('all')(1,:)) then
            start=%t
            imaginary=%t
 
         else
            start=%t
            imaginary=%f
         end
 
      end
 
      if imaginary then
         statk=part(statk,1:maybe_i(k)-1)+'*%'+part(statk,maybe_i(k):length(statk))
      end
 
   end
end
 
 
endfunction
