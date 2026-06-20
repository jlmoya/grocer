function sa = dttostr(x,fmt)
 
// PURPOSE: mimics gauss function dttostr: Converts a matrix
// containing dates in DT scalar format to a string array
// ------------------------------------------------------------
// INPUT:
// * x = (N x k) matrix containing dates in DT scalar format
// * fmt = string containing date/time format characters
// ------------------------------------------------------------
// OUTPUT:
// sa = (N x k) string array
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[YYYY, month, day, hour, minute, second] = explodt(x)
YR=(YYYY-floor(YYYY*0.01)*100)
YR=fillwithzero(string(YR),2,'l')
month=fillwithzero(string(month),2,'l')
day=fillwithzero(string(day),2,'l')
hour=fillwithzero(string(hour),2,'l')
minute=fillwithzero(string(minute),2,'l')
second=fillwithzero(string(second),2,'l')
fmt=strsubst(fmt,'YYYY','''+string(YYYY)+''')
fmt=strsubst(fmt,'YR','''+YR+''')
fmt=strsubst(fmt,'MO','''+month+''')
fmt=strsubst(fmt,'DD','''+day+''')
fmt=strsubst(fmt,'HH','''+hour+''')
fmt=strsubst(fmt,'MI','''+minute+''')
fmt=strsubst(fmt,'SS','''+second+''')
ind1=strindex(fmt,'+''')
if isempty(strsubst(part(fmt,ind1($)+2:length(fmt)),' ','')) then
  fmt=part(fmt,1:ind1($)-1)
else
  fmt=fmt+''''
end
ind1=strindex(fmt,'''+')
if isempty(strsubst(part(fmt,1:ind1(1)-1),' ','')) then
  fmt=part(fmt,ind1(1)+2:length(fmt))
else
  fmt=''''+fmt
end
 
execstr('sa='+fmt)
 
endfunction
