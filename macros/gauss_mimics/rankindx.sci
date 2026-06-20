function y = rankindx(x,flag);
 
// PURPOSE: mimics gauss function rankindx: Returns the vector
// of ranks of a vector
// ------------------------------------------------------------
// INPUT:
// * x = (N x 1) vector
// * flag = scalar, 1 for numeric data or 0 for character data
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x 1) containing the ranks of x. That is, the rank
// of the largest element is N and the rank of the smallest is
// 1. (To get ranks in descending order, subtract y from N+1).
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[junk,y]=gsort(x,'g','i')
//y=[]
//for i=1:size(z,'*')
//   t=find(z(i)==x)
//   y=[y ; t']
//end
 
endfunction
