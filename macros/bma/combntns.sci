function c=combntns(x,k,d)
 
// PURPOSE: provide all combinations of k elements in a
// vector x
//---------------------------------------------------------
// INPUT:
// * x = a vector of constant, string, boolean type
// * k = the number of elements to choose
// * d = 'c' or 'r' according to the desired orientaion of
//   the draws
//---------------------------------------------------------
// OUTPUT:
// c = a matrix, with k elements taken from x on each row
//     (case d='r') or col (case d='c')
//---------------------------------------------------------
// Copyright M. Baudin - E. Dubois (2011)
// http://grocer.toolbox.free.fr/grocer.html
 
 
if k==1 then
   c=x(:)
 
elseif typeof(x)=="constant"  then
   x=x(:)'
   n = size(x,"*")
   r = gammaln ( n + 1 ) - gammaln (k + 1) - gammaln (n - k + 1)
   b = exp( r )
   cnk = round ( b )
   c = zeros(cnk,k)
   a = 1:k
   c(1,:) = x(a)
   for m = 2 : cnk
      r = k : -1 : 1
      i = k - find ( a(r) <> n - k + r , 1 ) + 1
      a(i) = a(i) + 1
      j = i+1:k
      if ~isempty(j) then
         a(j) = a(i) + j - i
      end
      c(m,:) = x(a)
    end
else
 
   // String, boolean, integer...
      imap = specfun_subset((1:n),k,d);
      c = matrix(x(imap),cnk,k);
end
 
if d =='c' then
   c=c'
end
 
endfunction
