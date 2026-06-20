function %ts_p(ts)
 
// PURPOSE: provide a user friendly representation of ts
// ------------------------------------------------------------
// INPUT:
// * ts = a timeseries
// ------------------------------------------------------------
// OUPTUT:
// * nothing
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
s=full(ts('series'))
fq=ts('freq')
dat=ts('dates')
 
if fq == [365 1] then
// the data are daily or weekly
// drop the na values from the display
   indnonna=~isnan(s)
   if or(indnonna) then
      dat=dat(indnonna)
      s=s(indnonna)
   end
end
 
s=[' ' ; string(s)]
datlit=[' ' ; num2date(dat,fq) ]
 
L1=max(length(datlit)) ;
L2=max(length(s)) ;
 
// do the concatenation of the columns
t=part(datlit,1:L1+1)+part(s,1:L2+1)
// print the comment if any
if or(ts(1) == 'comment') then
   write(%io(2),ts('comment'))
end
 
write(%io(2),t,'(a)')
 
endfunction
