function [result] = recserar(x,y0,a)
 
// PURPOSE: mimic gauss function recserar: computes a vector of
// autoregressive recursive series
//--------------------------------------------------------------
// INPUT:
// * x  = a matrix of dimensions (n,k)
// * y0 = a matrix of dimensions (p,k)
// * a  = a matrix of dimensions (p,k)
//--------------------------------------------------------------
// OUTPUT:
// results(1:n,1:k) = contains columns computed
// recursively with:
//  - result=y0 for rows 1:p
//  - result(j,:)=result(j-1,:).*a(1:p,:) + x(j,:) for rows p+1:n
//--------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a matlab program by:
// Kit Baum
// Dept of Economics
// Boston College
// Chestnut Hill MA 02467 USA
// baum@bc.edu
// 9525
 
 
[nargout,nargin]=argn(0)
if nargin~=3 then
  error("Wrong number of arguments to recserar");
end;
[n1,k1] = size(x);
[p1,k2] = size(y0);
[p2,k3] = size(a);
if k1~=k2 then
  error("x, y0 must have same number of columns");
end;
if k1~=k3 then
  error("x, a must have same number of columns");
end;
if p1~=p2 then
  error("recserar y0, a must have same number of rows");
end;
result = zeros(n1,k1);
 
result(1:p1,:) = y0(1:p1,:);
for j = p1+1:n1
   result(j,:) = x(j,:);
   for k = 1:p1
      result(j,:) = result(j,:)+a(k,:) .*result(j-k,:);
   end
end
 
endfunction
