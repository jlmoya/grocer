function boundsnum=longest_span(listtsy,listsmaty,mindat)

listobj=lstcat(listtsy,listsmaty)
nobj=length(listobj)
 
ts1=listobj(1)
fq1=ts1('freq')
datenum_start=zeros(nobj,1)
datenum_end=zeros(nobj,1)
nts=zeros(nobj,1)
 
for i=1:nobj
   tsi=listobj(i)
   s=tsi('series')
   nts(i)=size(s,2)
   tsi=listobj(i)
   fqi=freqts(tsi)
   if fqi ~= fq1 then
      error('series # '+string(i)+' has not the same freq as the previous ts')
   end
   d=datets(tsi)
   datenum_start(i)=d(1)
   datenum_end(i)=d($)
 
end

if mindat then
   dmin=min(datenum_start)
   dmax=max(datenum_end)
   boundsnum=[dmin:dmax]'
 
else
   dmin=max(datenum_start)
   dmax=min(datenum_end)
   y=zeros(dmax-dmin+1,sum(nts))
   ind1=0
   for i=1:nobj
      tsi=listobj(i)
      s=tsi('series')
      y(:,ind1+[1:nts(i)])=s([dmin:dmax]-datenum_start(i)+1,:)
      ind1=ind1+nts(i)
   end
   ind_bounds=longest_nonna(y,dir)
   boundsnum=[dmin:dmax]'
   boundsnum=boundsnum(ind_bounds)
end

endfunction
