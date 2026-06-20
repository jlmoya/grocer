function [x,boundsvarb,boundsnum,comments]=explots(listts,searchna,mindat)
 
// PURPOSE: from a list of ts find the greatest time span over
// which the series are simultaneously defined and non NA and
// store in a vector the corresponding values
// ------------------------------------------------------------
// INPUT:
// * listts= a list of ts
// * searchna = a boolean indicating whether to search the
//   longest non NA time span
// * mindat =
//   - %t if the user wants to take the min and max dates
//   over which any series exists
//   - %f if the user wants to take the time period over which
//   all series exist
// ------------------------------------------------------------
// OUTPUT:
// * x = a (T x k) real matrix
// * boundsvarb = a (2 x 1) string vector (of dates)
// * boundsnum = a (T x 1) integer vector (numerical coding of
//   dates)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005-2013
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
nobjects=length(listts)
 
ts1=listts(1)
fq1=ts1('freq')
dmin=zeros(nobjects,1)
dmax=zeros(nobjects,1)
comments=emptystr(nobjects,1)
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
   if size(s,1) ~= size(d,1) then
      error('dimensions of dates ('+string(size(d,1))+'rows) and series ('+string(size(s,1))+'rows) in ts #'+ string(i)+'do not match')
   end
   dmin(i)=d(1)
   dmax(i)=d($)
   if size(tsi(1),1) == 5 then
      comments(i)=tsi(5)
   end
 
 
end
 
if ~mindat then
   x=[]
   dmin=max(dmin)
   dmax=min(dmax)
   for i=1:nobjects
      tsi=listts(i)
      s=tsi('series')
      di=datets(tsi)
      ns=size(s,1)
      x=[x s(1+dmin-di(1):ns-di(ns)+dmax,:)]
   end
 
else
   dmin=min(dmin)
   dmax=max(dmax)
   x=%nan*ones(dmax-dmin+1,nobjects)
   nobjectsi=0
   for i=1:nobjects
      tsi=listts(i)
      di=datets(tsi)
      s=tsi('series')
      x(di-dmin+1,nobjectsi+1:nobjectsi+size(s,2))=s
      nobjectsi=nobjectsi+size(s,2)
   end
 
end
 
row_nonna=~or(isnan(x),'c')
if sum(row_nonna) ==  size(row_nonna,1) | ~searchna then
   boundsnum=[dmin:dmax]'
   boundsvarb=[num2date(dmin,fq1) ; num2date(dmax,fq1)]
else
   row_delnonna=[2*row_nonna(1)-1 ; bool2s(row_nonna(2:$))-bool2s(row_nonna(1:$-1)) ; -1]
   ind_debnonna=find(row_delnonna==1)
   row_delnonnab=row_delnonna(ind_debnonna(1)+1:$)
   deb_nonna=ind_debnonna(1)
   laux=find(row_delnonnab == -1)
   end_nonna=deb_nonna+laux(1)-1
   for i=2:size(ind_debnonna,2)
      row_delnonnab=row_delnonna(ind_debnonna(i)+1:$)
      laux=find(row_delnonnab==-1)
      if laux(1)-1 > end_nonna-deb_nonna then
         deb_nonna=ind_debnonna(i)
         end_nonna=deb_nonna+laux(1)-1
      end
   end
   x=x(deb_nonna:end_nonna,:)
   boundsnum=dmin-1+[deb_nonna:end_nonna]'
   boundsvarb=[num2date(dmin+deb_nonna-1,fq1) ; num2date(dmin+end_nonna-1,fq1)]
end
 
endfunction
 
