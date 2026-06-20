function y = code(e,v)
 
// PURPOSE: mimic Gauss function code: allows a new variable
// to be created (coded) with different values depending
// upon which one of a set of logical expressions is true.
// ------------------------------------------------------------
// INPUT:
// * e = (N x K) matrix of 1’s and 0’s. Each column of this
//   matrix is created by a logical expression using “dot”
//   conditional and boolean operators. Each of these
//   expressions should return a column vector result. The
//   columns are horizontally concatenated to produce e. If
//   more than one of these vectors contains a 1 in any given
//   row, the code function will terminate with an error
//   message
// * v = ((K+1) x 1) vector containing the values to be
//   assigned to the new variable
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x 1) vector containing the new values
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
K=size(v,'*')-1
N=size(e,1)
if or(e ~=1 & e~=0) then
   error('1st arg in e should have only 0 and 1')
end
 
f=find(cumsum(e,'c') > 1)
if ~isempty(f) then
   error('1st arg has more than one 1 at lines '+strcat(string(f),', '))
end
 
y=v(K+1)*ones(N,1)
for i=1:N
   ind=find(e(i,:) == 1)
   y(i)=ind
end
 
endfunction
