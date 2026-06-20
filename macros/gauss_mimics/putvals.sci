function x = putvals(x,inds,v)
 
// PURPOSE: mimic Gauss function putvals: inserts values into a
// matrix or N-dimensional array
// ------------------------------------------------------------
// INPUT:
// * x = a (M x K) matrix or N-dimensional array
// * inds = a (L x D) matrix of indices; specifying where the
//   new values are to be inserted; where D is the number of
//   dimensions in x
// * v = a (L x 1) vector; new values to insert
// ------------------------------------------------------------
// OUTPUT:
// * y = (M x K) matrix or N-dimensional array, copy of x
//   containing the new values in vals.
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
inds_str=string(inds)
for i=1:size(inds,1)
   execstr('x('+strcat(inds_str(i,:),';')+')=v('+string(i)+')')
end
 
endfunction
 
