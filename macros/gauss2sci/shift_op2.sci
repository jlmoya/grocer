function op=shift_op2(op,ind_nonempty,index,addon)
 
// PURPOSE: shifts the indexes of all operators located after
// a defined index in a (Gauss) statement
// ------------------------------------------------------------
// INPUT:
// * op = tlist of operators indexes
// * index = a scalar, the index after which to shift the
//   operators indexes
// * nb = a scalar, the shift  (can be positie or negative)
// ------------------------------------------------------------
// OUTPUT:
// * op = the shifted tlist of operators indexes
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
for i=ind_nonempty
   aux=op(i)
//   pause
   aux(2,aux(1,:)>index)=aux(2,aux(1,:)>index)+addon
   op(i)=aux
end
 
endfunction
