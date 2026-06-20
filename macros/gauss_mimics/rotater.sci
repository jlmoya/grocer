function y=rotater(x,r)
 
// PURPOSE: mimics gauss function rotater: rotates the rows of
// a matrix
// ------------------------------------------------------------
// INPUT:
// * x = a (N x k) matrix to be rotated
// * r = a (N x 1) or (1 x 1) matrix specifying the amount of
//   rotation
// ------------------------------------------------------------
// OUTPUT:
// * y =  a (N x k) rotated matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nr_r,nc_r]=size(r)
[nr_x,nc_x]=size(x)
 
if nc_r ~= 1 then
   error('# of cols of second argument should be 1')
end
 
if nr_r == 1 then
   ind_r=modulo(nc_x-r,nc_x)
   y=[x(:,ind_r+1:nc_x) x(:,1:ind_r)]
 
elseif nr_r ~= nr_x then
   error('# of rows of first and second arguments do not match')
 
else
   y=x
   for i=1:nr_r
      ind_r=modulo(nc_x-r(i),nc_x)
      y(i,:)=[x(i,ind_r+1:nc_x) x(i,1:ind_r)]
   end
 
end
 
endfunction
