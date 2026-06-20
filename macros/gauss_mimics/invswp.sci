function y=invswp(x)
 
// PURPOSE: mimic gauss function invswp: computes a generalized
// sweep inverse
// ------------------------------------------------------------
// INPUT:
// * x = (N x N) matrix
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x N) matrix, the generalized inverse of x
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
//tol=sysstate(13,-1)
n=size(x,1)
 
[R,D]=spec(x)
eig_zeros=find(abs(diag(D))<tol)
nzeros=size(eig_zeros,2)
indexes=[]
for i=1:nzeros
   [val,ind_i]=gsort(abs(R(:,eig_zeros(i))),'g','d')
   indexes=[indexes ind_i ]
end
 
mat_ind=zeros(n^nzeros,nzeros)
for i=1:nzeros
   mat_ind(:,i)=ones(n^(i-1),1) .*. indexes(:,i) .*. (ones(n^(nzeros-i),1))
end
 
done=%f
i=1
y=zeros(n,n)
while ~done then
   ind=mat_ind(i,:)
   inds=gsort(ind,'g','i')
   delinds=inds(2:$)-inds(1:$-1)
   if and(delinds ~= 0) then
      nonind=1:n
      nonind(ind)=[]
      b=x(nonind,nonind)
      [R,D]=spec(b)
      if min(abs(diag(D))) >  tol then
         y(nonind,nonind)=inv(b)
         done=%t
      end
   end
end
 
endfunction
 
