function z = crossprd(x,y)
 
// PURPOSE: mimic Gauss function crossprd: computes the cross-
// products (vector products) of sets of (3 x 1) vectors
// ------------------------------------------------------------
// INPUT:
// * x = (3 x K) matrix, each column is treated as a (3 x 1)
//   vector
// * y = (3 x K) matrix, each column is treated as a (3 x 1)
//   vector
// ------------------------------------------------------------
// OUTPUT:
// * z = (3 x K) matrix, each column is the cross-product
//  (sometimes called vector product) of the corresponding
//  columns of x and y
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
z = x([2 3 1],:).*y([3 1 2],:)-y([2 3 1],:).*x([3 1 2],:)
 
 
endfunction
