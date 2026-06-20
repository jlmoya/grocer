function x=rndp(r,c,lambda)
 
// PURPOSE: mimics gauss function rndp: computes pseudo-random
// numbers with Poisson distribution
// ------------------------------------------------------------
// INPUT:
// * r = scalar, number of rows of resulting matrix
// * c = scalar, number of cols of resulting matrix
// * lambda = (M x N) matrix, (E x E) conformable with r x c
//   resulting matrix, shape parameters for Poisson
//   distribution
// ------------------------------------------------------------
// OUTPUT:
// * y =  a (r x c) matrix, Poisson distributed pseudo-random
//   numbers
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[lr,lc]=size(lambda)
x=zeros(r,c)
if lr == 1 & lc ==1 then
   x=grand(r,c,'poi',lambda)
 
elseif lr==1 then
   for j=1:lc
      x(:,j)=grand(r,1,'poi',lambda(j))
   end
 
elseif lc==1 then
   for i=1:lr
      x(i,:)=grand(1,c,'poi',lambda(i))
    end
else
   for i=1:lr
      for j=1:lc
         x(i,j)=grand(1,1,'poi',lambda(i,j))
      end
   end
end
 
endfunction
