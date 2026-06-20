function %coeffs_p(coeffs)
 
// PURPOSE:
// ------------------------------------------------------------
// INPUT:
// * coeffs = the coeff field from a model tlist
// ------------------------------------------------------------
// OUTPUT:
// NOTHING: the functiion is used only for display purposes
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015-2016
// http://grocer.toolbox.free.fr/grocer.html
 
if length(coeffs) == 1 then
   write(%io(2),'no coeffs in model','(a)')
else
   coeffs_1=coeffs(1)(2:$)
   ncoeffs=size(coeffs_1,1)
   coeffs_2=emptystr(ncoeffs,1)
   for i=1:size(coeffs_1,1)
      if ~isempty(coeffs(i+1)) then
         coeffs_2(i)=string(coeffs(i+1))
      end
   end
   mat2prt=[coeffs_1 , coeffs_2]
   printmat(mat2prt,%io(2))
end
 
endfunction
