function str = datestrymd(d)
 
// PURPOSE: mimic Gauss function datestrymd: returns a date in
// a string
// ------------------------------------------------------------
// INPUT:
// * d = a (4 x 1) vector, like the date function returns. If
// this is 0, the date function will be called for the current
// system date
// ------------------------------------------------------------
// OUTPUT:
// * str = 8 character string containing current date in the
//   form: yyyymmdd
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
str=strcat(d(1:3),'')
 
endfunction
