function [yscaled,scal]=scalemat(y)
 
// PURPOSE: rescale colums of matrix y to an O(1) order
// ------------------------------------------------------------
// INPUT:
// * y= a (n x k) real variable
// ------------------------------------------------------------
// OUTPUT:
// * yscaled = the (n x k) rescaled matrix
// * scale = the (1xk) vector such as :
//   y(:,i) = yscaled(:,i)*(10^scale(i))
// ------------------------------------------------------------
// Copyright Eric Dubois 2006
// http://grocer.toolbox.free.fr/grocer.html
 
[T,k]=size(y)
scal=zeros(1,k)
for i=1:k
   y_i=y(:,i)
   scal(i)=round(log10(mean(abs(y_i(~isnan(y_i))+sqrt(%eps)))))
end
 
yscaled=y ./ (ones(T,1) .*. 10^scal)
 
endfunction
