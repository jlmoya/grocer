function prt_vargranger(res,out)
   
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
write(out,' ')
rvar=res('rvar res')
namey=rvar('namey')
causing=res('causing')
if size(causing,'*') == 1 then
   name_causing='variable '+namey(causing)
elseif size(causing,'*') == 2 then
   name_causing='variables '+namey(causing(1))+' and '+namey(causing(2))
else
   name_causing='variables '+namey(causing(1))+', '+strcat(namey(causing(2:$-1)),', ')+' and '+namey(causing($))
end

caused=res('caused')
if size(caused,'*') == 1 then
   name_caused='variable '+namey(caused)
elseif size(caused,'*') == 2 then
   name_caused='variables '+namey(caused(1))+' and '+namey(caused(2))
else
   name_caused='variables '+namey(caused(1))+', '+strcat(namey(caused(2:$-1)),', ')+' and '+namey(caused($))
end

write(out,'VAR Granger non-causality test')
write(out,'from '+name_causing+' to '+name_caused)

prtchi(res,out)
prtfish(res,out)
   
endfunction
