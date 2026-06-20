function [justified,fmt_numbers,str]=percent2fmt(str)
 
// PURPOSE: extract from a format starting with '%' the
// information regarding the justification and the display
// type
// ------------------------------------------------------------
// INPUT:
// * str= a string starting with '%'
// ------------------------------------------------------------
// OUTPUT:
// * justified = the kind of justification
// * fmt_numbers = the display type
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
justified='r'
if part(str,1) == '-' then
   justified='l'
   str=stripblanks(part(str,2:length(str)))
end
if part(str,1) == '#' then
   fmt_numbers='o'
   str=stripblanks(part(str,2:length(str)))
end
if part(str,1:3) == '*.*' then
   str=stripblanks(part(str,4:length(str)))
end
 
if ~exists('fmt_numbers','local') then
   if part(str,1) == 's' then
      fmt_numbers='s'
   else
      fmt_numbers=convstr(part(str,1:2))
   end
end
str=part(str,3:length(str))
 
endfunction
