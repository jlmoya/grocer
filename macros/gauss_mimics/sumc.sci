function b=sumc(a)
 
// PURPOSE: mimics gauss function sumc: Computes the sum of
// each column of a matrix or the sum across the second-fastest
// moving dimension of an L-dimensional array
// ------------------------------------------------------------
// INPUT:
// * a = (N x K) matrix or L-dimensional array where the last
//   two dimensions are (N x K)
// ------------------------------------------------------------
// OUTPUT:
// * b = (K x 1) vector or L-dimensional array where the last
//   two dimensions are K×1
// ------------------------------------------------------------
// NOTE:
// for arrays, the function can probably be made more
// efficient...
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
dims=size(a)
ndims=size(dims,'*')
 
select ndims
 
case 2 then
   b=sum(a,'r')'
 
else
   execstr('b=ones('+strcat(string(dims([1 3:ndims])),',')+',1)')
   str1='for i=1:dims(1);'
   str2='b(i'
   str3=',1)=sum(a(i,:'
   str4='end'
   for i=1:size(dims,'*')-2
      str1=str1+'for k'+string(i)+'=1:'+string(dims(i+2))+';'
      str2=str2+',k'+string(i)
      str3=str3+',k'+string(i)
      str4=str4+';end'
   end
   str=str1+str2+str3+'));'+str4
   execstr(str)
 
 
end
 
endfunction
