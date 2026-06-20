function y=areshape(x,orders)
 
// PURPOSE: mimic Gauss function areshape: reshapes a scalar,
// matrix, or array into an array of user-specified size
// ------------------------------------------------------------
// INPUT:
// * x = scalar, matrix, or N-dimensional array
// * orders = (M x 1) vector of orders, the sizes of the
//   dimensions of the new array
// ------------------------------------------------------------
// OUTPUT:
// * y = M-dimensional array, created from data in x
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
m=[]
n=cumprod(orders)
norders=size(orders,'*')
ny=n($)
nmat2=orders($-1)*orders($)
x=x'
nx=size(x,'*')
fact=floor(ny/nx)
rest=ny-fact*nx
xnew=[ones(fact,1) .*. x(:) ; x(1:rest)]
 
if size(orders,'*') <= 2 then
   execstr('y=matrix(xnew,'+strcat('orders('+string(1:size(orders,'*')),'),')+'))''')
 
else
   j1=1
   y=arrayinit(orders,1)
   str1=emptystr()
   str2='y('
   str4=emptystr()
 
   for i=1:norders-2
      str1=str1+'for k'+string(i)+'=1:'+string(orders(i))+';'
      str2=str2+'k'+string(i)+','
      str4=str4+';end'
   end
   str='j2=nmat2;'+str1+str2+':,:)=matrix(xnew(j1:j2),orders($),orders($-1))'';j1=j2+1;j2=j2+nmat2'+str4
   execstr(str)
 
end
 
endfunction
 
