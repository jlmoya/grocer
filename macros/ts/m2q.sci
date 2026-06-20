function ts_q=m2q(ts,ind)
 
// PURPOSE: transform monthly data into quarterly ones
// ------------------------------------------------------------
// INPUT:
// * ts = a monthly timeseries
// * ind =
//   - -1 if the quarterly data is to be the sum of the
// corresponding months
//   - 0 if the quarterly data is to be the mean of the
// corresponding months
//   - 1 if the quarterly data is to be the value of the
// first month
//   - 2 if the quarterly data is to be the value of the
// second month
//   - 3 if the quarterly data is to be the value of the
// third month
// ind is optional; if not provided, it is set to -1
// ------------------------------------------------------------
// OUTPUT:
// * ts = the corresponding quarterly time series
// ------------------------------------------------------------
// NOTE: if ind=0 or -1, the only full quarters are filled
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2010
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
 
if ind == 0 then
   divisor=3
else
   divisor=1
end
 
d=datets(ts)
s=series(ts)
 
if ind < 1 then
 
// retrieve the first month of the full quarter
// and its index in the vectors series, listna or dates
// calculate the number of full quarters
// and transform the listna and series in order
// to have the 3 monthly values of one quarter
// on the rows of the matrix mtrans and natrans
   divisor=3+2*ind
   deb_m=modulo(d(1)-1,3)
   deb_ind=modulo(3-deb_m,3)+1
   deb_q=(d(deb_ind)-1)/3+1
   nquarters=floor((size(s,1)-deb_ind+1)/3)
   if nquarters == 0 then
      write(%io(2),'in m2q, not enough monthly data to build a quarter','(a)')
   end
// calculate and put in an array the annual data
   if typeof(ts) == 'ts' then
      snew=matrix(s(deb_ind:deb_ind-1+3*nquarters,:),3,-1)'
      ts_q=tlist(['ts';'freq';'dates';'series'],[4 1],[deb_q:deb_q+nquarters-1]',sum(snew,'c')/divisor)
   else
      nts=size(s,2)
      snew=zeros(nquarters,nts)
      for i=1:nts
         snew(:,i)=sum(matrix(s(deb_ind:deb_ind-1+3*nquarters,i),3,-1)','c')
      end
      ts_q=tlist(['tsmat';'freq';'dates';'series';'names'],[4 1],[deb_q:deb_q+nquarters-1]',snew/divisor,ts('names'))
   end
 
else
 
   deb_ind=1+modulo(3-modulo(d(1)-ind,3),3)
   end_ind=size(d,1)-modulo(d(size(d,1))-ind,3)
   nquarters=(end_ind-deb_ind)/3+1
   deb_q=(d(deb_ind)-ind)/3+1
// take the series between the first and the last
// existing month of the required type and fill with 1
// to obtain a vector with a suitable length (a multiple of
   if typeof(ts) == 'ts' then
      ts_q=tlist(['ts';'freq';'dates';'series'],[4 1],[deb_q:deb_q+nquarters-1]',s(deb_ind:3:end_ind,:))
   else
      ts_q=tlist(['tsmat';'freq';'dates';'series';'names'],[4 1],[deb_q:deb_q+nquarters-1]',s(deb_ind:3:end_ind,:),ts('names'))
   end
end
 
 
endfunction
