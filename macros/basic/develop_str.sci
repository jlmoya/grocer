function str=develop_str(str,set_names)
 
// PURPOSE:
// ------------------------------------------------------------
// INPUT:
// *
// ------------------------------------------------------------
// OUTPUT:
// *
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018
// http://grocer.toolbox.free.fr/grocer.html
 
 
str=str(:)
str=strsubst(str,',',';')
if size(str,1) == 1  then
   str=evstr('['''+strsubst(str,';',''';''')+''']')
end
 
// find in the list of strings if there are masks
for i=size(str,1):-1:1
   if ~isempty(strindex(str(i),'>')) | ~isempty(strindex(str(i),'*')) then
     [str_i]=select_mask(set_names,str(i))
     str=[str(1:i-1) ; str_i ; str(i+1:$)]
   end
end
 
endfunction
