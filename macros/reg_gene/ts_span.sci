function [datenum_start,datenum_end]=ts_span(listts)
    
nobjects=length(listts)
 
ts1=listts(1)
fq1=ts1('freq')
datenum_start=zeros(nobjects,1)
datenum_end=zeros(nobjects,1)
nts=0
 
for i=1:nobjects
   tsi=listts(i)
   s=tsi('series')
   nts=nts+size(s,2)
   tsi=listts(i)
   fqi=freqts(tsi)
   if fqi ~= fq1 then
      error('series # '+string(i)+' has not the same freq as the previous ts')
   end
   d=datets(tsi)
   datenum_start(i)=d(1)
   datenum_end(i)=d($)
 
end
 
endfunction
