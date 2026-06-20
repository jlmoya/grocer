function y=mean0(x,orient)

[lhs,rhs]=argn(0)
 
if rhs==1 then
   if x==[] then y=%nan;return,end
   y=sum(x)/size(x,'*')
else
   if x==[] then y=[];return,end
   y=sum(x,orient)/size(x,orient)
end



endfunction