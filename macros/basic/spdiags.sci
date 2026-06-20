function B = spdiags(A,d,m,n)
 
 
// mimics matlab function spdiags
 
[nargout,nargin]=argn(0)
 
select nargin
 
case 4 then
 
   select sign(m-n)
 
   case -1 then
 
      p=size(d,'*')
      d1=d(1)
      B=diag(A(:,1),d1)
      B=B(max(0,-d1)+[1:m],max(1,-d1+1):n+max(0,-d1))
      for i=2:p
         di=d(i)
         diagi=diag(A(:,i),d(i))
         diagi=diagi(max(0,-di)+[1:m],max(1,-di+1):n+max(0,-di))
         B=B+diagi
      end
 
   case 0 then
 
      p=size(d,'*')
      nB=size(A,1)-min(abs(d))
      B=diag(A(:,1),d(1))
      B=B(1:m,1:m)
      for i=2:p
         di=d(i)
         diagi=diag(A(:,i),d(i))
         diagi=diagi(max(1,di+1):m+max(0,di),max(1,di+1):m+max(0,di))
         B=B+diagi
      end
 
   case 1 then
 
      p=size(d,'*')
      d1=d(1)
      B=diag(A(:,1),d1)
      B=B(max(1,d1+1):m+max(0,d1),max(1,d1+1):n+max(0,d1))
      for i=2:p
         di=d(i)
         diagi=diag(A(:,i),d(i))
         diagi=diagi(max(1,di+1):m+max(0,di),max(1,di+1):n+max(0,di))
         B=B+diagi
      end
 
   end
 
end
 
endfunction
 
