function [str_left,str_right] = token(str)
 
// PURPOSE: mimic gauss function parse: Extracts the leading
// token from a string
// ------------------------------------------------------------
// INPUT:
// * str = string, the string to parse
// ------------------------------------------------------------
// OUTPUT:
// * str_left = string, the first token in str
// * str_right = string, str minus token.
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
ind1=strindex(str,' ')
ind2=strindex(str,',')
len=length(str)
ind=[gsort([ind1 ind2],'g','i') len+1]
ind1=ind(1)
str_left=part(str,1:ind1-1)
 
n=size(ind,2)
i=1
while i<=n-1 & ind(i) == ind(i+1)-1
   i=i+1
end
if ind(i) == len+1 then
   str_right=emptystr()
else
   str_right=part(str,ind(i)+1:len)
end
 
 
endfunction
