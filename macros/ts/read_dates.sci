function [datn,inddates,fq,reverse]=read_dates(dat)
 
// PURPOSE: read a series of dates and give their frequency
// (a subroutine of functions impexc2bd and readxls
// ------------------------------------------------------------
// INPUT:
// * dat=a (m x 1) string vetor of dates
// ------------------------------------------------------------
// OUTPUT:
// * datn = a (n x 1) constant vector [n1:n2] with n1 the
//   numerical representation of the first date in dat and n2
//   the numerical representation of the last date in dat
// * inddates = a (m x 1) constant vectors representing the
//   indexes of the dates corresponding to datn in dat
// * fq = the frequency of the dates
// * reverse = %t if the dates were entered in reverse
//   chronological order
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
reverse=%f
dat=vec2col(dat)
nc=size(dat,1)
inddates=[1:nc]
// find dates that are not empty
datfilled=find(dat ~= '' & dat ~= '%nan')
// transform them in numbers
datnum=date2num_m(dat(datfilled))
ndates=max(datnum)-min(datnum)+1
datn=zeros(nc,1)*%nan
datn(datfilled)=datnum
fq=date2fq(dat(datfilled(1)))
 
if size(datfilled,2) ~= nc then
   warning('incomplete dates in your csv file:')
   write(%io(2),'lacking dates have been filled','(a)')
   write(%io(2),' ','(a)')
   datn=extrapna(datn)
end
 
deldat=datn(2:$)-datn(1:$-1)
 
ndates=size(datnum,1)
deldat=datn(2:nc)-datn(1:nc-1)
 
if and(deldat < 0) then
   warning('dates were entered in reverse chronological order: function puts them in chronological order and sort the data after accordingly')
   write(%io(2),' ','(a)')
   [datn,inddates]=gsort(datn,'g','i')
   reverse=%t
 
elseif or(deldat < 0) then
   f=find(deldat<0)
   if size(f,2) == 1 then
      [fq,fqlit]=date2fq(dat(f))
		
      if fqlit == 'da' then
         load(GROCERDIR+'\param\dailyform.dat')
         ind=strindex(dat(f),grocer_dailysep)
         d1=dat(f)
         execstr('p='+[part(d1,1:ind(1)-1) ; part(d1,ind(1)+1:ind(2)-1) ; ...
           part(d1,ind(2)+1:length(d1))])
         year1=p(grocer_dailypart(1))
         year1b=1900+p(grocer_dailypart(1))
         d2=dat(f+1)
         execstr('p='+[part(d2,1:ind(1)-1) ; part(d2,ind(1)+1:ind(2)-1) ; ...
           part(d2,ind(2)+1:length(d2))])
         year2=p(grocer_dailypart(1))
         year2b=2000+p(grocer_dailypart(1))
 
         if year1 == 99 & year2 == 0 then
            datnum=datnum+693960+36525*[zeros(f,1);ones(ndates-f,1)]
            datlita=['yy';'mm';'dd' ]
            datlitb=['yyyy';'mm';'dd' ]
            dd2a=joinstr(datlita(grocer_dailypart),grocer_dailysep)
            dd2b=joinstr(datlitb(grocer_dailypart),grocer_dailysep)
            warning('dates are entered as: '+dd2a)
            write(%io(2),'and are supposed to be of the form '+dd2b,'(a)')
         else
            error('dates are entered neither in chronlogical order nor in reverseerse chronological order')
         end
 
      else
         error('dates are entered neither in chronlogical order nor in reverseerse chronological order')
      end
   end
end
 
fq=date2fq(dat(datfilled(1)))
if 7*size(deldat,1)-6 <= sum(deldat) & sum(deldat) <= 7*size(deldat,1)+6 then
   // suspect that series are weekly
   warning('series are supposed to be weekly ones')
   datn=date2num_m(dat(datfilled),'w')
   fq=[52 1]
end
 
if or(datn(2:$)-datn(1:$-1) ~= 1) then
   warning('dates are not contiguous in your database')
   write(%io(2),' ','(a)')
end
 
inddates=datn-datn(1)+1
datn=[min(datn):max(datn)]'
 
endfunction
 
