function [datn,fq,index]=filldates(dat,nc)
 
index=[1:nc]
dat=vec2col(dat)
datn=zeros(nc,1)*%nan
datfilled=find(dat ~= '')
datn(datfilled)=date2num_m(dat(datfilled))
fq=date2fq(dat(datfilled(1)))
 
if size(datfilled,2) ~= nc then
   warning('incomplete dates in your csv file:')
   write(%io(2),'lacking dates have been filled','(a)')
   write(%io(2),' ','(a)')
   datn=extrapna(datn)
end
 
deldat=datn(2:$)-datn(1:$-1)
 
if or(deldat ~= 1) then
   warning('dates were not entered in chronological order: function puts them in chronological order and sort the data after accordingly')
   write(%io(2),' ','(a)')
   [datn,index]=gsort(datn,'g','i')
end
 
if or(datn(2:nc)-datn(1:nc-1) ~= 1) then
   warning('dates are not contiguous in your database')
   write(%io(2),' ','(a)')
end
 
endfunction
