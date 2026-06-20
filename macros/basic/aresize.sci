function xn=aresize(x,dimsnew)
 
// PURPOSE: resize x along dimensions dims
// ------------------------------------------------------------
// INPUT:
// * varargin = arrays conformable
// ------------------------------------------------------------
// OUTPUT:
// * a = (nx x mx) matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
dims=[size(x) ones(1,size(dimsnew,2)-size(size(x),2))]
if and(dims($-1:$) == 1) then
   xn=arrayinit(dimsnew,1)
   for i=1:dimsnew($-1)
      for j=1:dimsnew($)
         execstr('xn(1:'+strcat(string(dims(1:$-2)),',1:')+...
            ','+string(i)+','+string(j)+')=x(1:'+strcat(dims,',1:')+')')
      end
   end
 
elseif dims($) == 1 then
  for j=1:dimsnew($)
     execstr('xn(1:'+strcat(string(dims(1:$-1)),',1:')+','+...
          string(j)+')=x(1:'+strcat(string(dims(1:$-1)),',1:')+',1)')
   end
 
elseif dims($-1) == 1 then
   for j=1:dimsnew($-1)
      execstr('xn(1:'+strcat(string(dims(1:$-2)),',1:')+','+...
         string(j)+','+string(dimsnew($))+')=x(1:'+strcat(string(dims(1:$-2)),',1:')+',1,1:'+...
         string(dims($))+')')
   end
else
   xn=x
end
 
endfunction
