function ts_a=m2a(ts,ind)
 
// PURPOSE: transforms monthly data into quarterly ones
// ------------------------------------------------------------
// INPUT:
// * ts = a quarterly timeseries
// * ind =
//   - -1 if the annual data is to be the sum of the
// corresponding months
//   - 0 if the annual data is to be the mean of the
// corresponding months
//   - i if the annual data is to be the value of the
// i-th month
// ind is optional; if not provided, it is set to -1
// ------------------------------------------------------------
// OUTPUT:
// * ts = the corresponding quarterly time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2012
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   ind=-1
end
 
typeof_ts=typeof(ts)
if and(typeof_ts ~= ['ts' 'tsmat']) then
   error('m2q applies only to ts or tsmat and not to '+typeof_ts)
end
 
if ts('freq') ~= 12 then
   error('your '+typeof_ts+' should have frequency 12')
end
 
d=datets(ts)
s=series(ts)
 
if ind < 1 then
 
// retrieve the first quarter of the full year
// and its index in the vectors series, listna or dates
// calculate the number of full years
// and transform the listna and series in order
// to have the 12 quarterly values of one year
// on the rows of the matrix mtrans and natrans
// set div to 1 if ind=-1, to 12 if ind=0
   divisor=12+11*ind
   deb_m=modulo(d(1)-1,12)
   deb_ind=modulo(12-deb_m,12)+1
   deb_a=(d(deb_ind)-1)/12
   nyears=floor((size(s,1)-deb_ind+1)/12)
   if nyears == 0 then
      write(%io(2),'in m2a, not enough monthly data to build a year','(a)')
   end
   val=%nan*ones(nyears,1)
   snew=matrix(s(deb_ind:deb_ind-1+12*nyears,:),12,-1)'
// calculate and put in an array the annual data
   if typeof(ts) == 'ts' then
      snew=matrix(s(deb_ind:deb_ind-1+12*nyears,:),12,-1)'
      ts_a=tlist(['ts';'freq';'dates';'series'],[1 1],[deb_a:deb_a+nyears-1]',sum(snew,'c')/divisor)
   else
      nts=size(s,2)
      snew=zeros(nquarters,nts)
      for i=1:nts
         snew(:,i)=sum(matrix(s(deb_ind:deb_ind-1+12*nyears,i),3,-1)','c')
      end
      ts_a=tlist(['tsmat';'freq';'dates';'series';'names'],[1 1],[deb_a:deb_a+nyears-1]',snew/divisor,ts('names'))
   end
 
else
 
// deb_ind is the index of the first value belonging to the
// chosen quarter
   deb_ind=1+modulo(12-modulo(d(1)-ind,12),12)
   end_ind=size(d,1)-modulo(d(size(d,1))-ind,12)
   nyears=(end_ind-deb_ind)/12+1
   if nyears == 0 then
      write(%io(2),'in m2a, not enough quarterly data to build a year','(a)')
   end
   deb_a=(d(deb_ind)-ind)/12
// take the series between the first and the last
// existing quarter of the required type and fill with 1
// to obtain a vector with a suitable length (a multiple of
// 12)
   if typeof(ts) == 'ts' then
      ts_a=tlist(['ts';'freq';'dates';'series'],[1 1],[deb_a:deb_a+nyears-1]',s(deb_ind:12:end_ind,:))
   else
      ts_a=tlist(['tsmat';'freq';'dates';'series';'names'],[1 1],[deb_a:deb_a+nyears-1]',s(deb_ind:12:end_ind,:),ts('names'))
   end
 
end
 
 
endfunction
