function op=shift_op(op,ind_nonempty,index,nb)
 
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
   aux(1,aux(1,:)>=index)=aux(1,aux(1,:)>=index)+nb
   aux(3,aux(1,:)>=index)=aux(3,aux(1,:)>=index)+nb*and(i~=[41;42])
   op(i)=aux
end
 
endfunction
