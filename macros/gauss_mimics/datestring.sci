function str = datestring(d)
 
// PURPOSE: mimic Gauss function datestring: returns a date in
// a string with a 4-digit year
// ------------------------------------------------------------
// INPUT:
// * d = a (4 x 1) vector, like the date function returns. If
// this is 0, the date function will be called for the current
// system date
// ------------------------------------------------------------
// OUTPUT:
// * str = 10 character string containing current date in the
//   form: mm/dd/yyyy
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
if d==0 then
   d=date_gauss()
end
d=string(d)
z=['0000' '00' '00']
for i=1:3
   d(i)=part(z(i),1:length(z(i))-length(d(i)))+d(i)
end
str=strcat(string(d([2:3 1])),'/')
 
endfunction
