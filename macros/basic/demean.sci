function [XC] = demean(X,dim)
 
[T,n] = size(X);
meanX=mean0(X,dim)
[nr,nc]=size(meanX)
if nr == 1 then
   XC = X - ones(T,1)*meanX
else
   XC = X - meanX*ones(1,n)
end
 
endfunction
 
