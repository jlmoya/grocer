function ts=da2m(ts,ind,dropna)
 
// PURPOSE: transforms daily data into monthly ones
// ------------------------------------------------------------
// INPUT:
// * ts = a daily timeseries
// * ind =
//   - -1 if the monthly data is to be the sum of the
// corresponding days
//   - 0 if the  monthly data is to be the mean of the
// corresponding days
//   - n between 1 and 28 if the monthly data is to be the
//     value of the n-th day of the month
//   - n > 29 if the monthly data is to be the value of the
//     last day of the month
// ind is optional; if not provided, it is set to -1
// * dropna = 'dropna' if the user wants to withdraw all NA
//   values from the calculations (case ind=0 or -1) or to take
//   the last non NA value of the quarter (case ind > 90)
// if not entered then all NA values are considered
// ------------------------------------------------------------
// OUTPUT:
// * ts = the corresponding monthly time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007-2021
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   ind=-1
end
if nargin < 3 then
   dropna=%f
elseif dropna== 'dropna' then
   dropna=%t
end
 
d=datets(ts)
s=series(ts)
k=size(s,2)
 
dat=num2date(d(1),365)
indsep=strindex(dat,'/')
execstr('year='+part(dat,1:indsep(1)-1))
execstr('month='+part(dat,indsep(1)+1:indsep(2)-1))
execstr('day='+part(dat,indsep(2)+1:length(dat)))
 
if ind < 1 then
// retrieve the first day of the full month
// and its index in the vectors series, listna or dates
// calculate the index of the first and of the last full months
 
   if day == 1 then
      // the first date is the beginning of a month
      ind_start=1
      month_start=month
   else
 
      if month == 12 then
         // the first full month begins the year after
         year_start=year+1
         month_start=1
      else
         year_start=year
         month_start=month+1
      end
      day_start=1
      ind_start=datenum(year_start,month_start,day_start)-d(1)+1
   end
   dat0=year*12+month_start
   dat=num2date(d($)+1,365)
   execstr('year='+part(dat,1:indsep(1)-1))
   execstr('month='+part(dat,indsep(1)+1:indsep(2)-1))
   execstr('day='+part(dat,indsep(2)+1:length(dat)))
 
   if day == 1 then
      // this means that the last period was the end of a month
      ind_end=size(d,1)
   else
      ind_end=datenum(year,month,1)-d(1)
   end
 
   s=s(ind_start:ind_end,:)
   d=d(ind_start:ind_end)
   dvec=datevec(d)
   monthvec=dvec(:,2)
   dmonthvec=monthvec(2:$)-monthvec(1:$-1)
   ind_nonzero=find(dmonthvec ~= 0)
   if isempty(ind_nonzero) then
      changmonth=[1 ind_end-ind_start+2]
   else
      changmonth=[1 find(dmonthvec ~= 0)+1 ind_end-ind_start+2]
   end
   nmonth=size(changmonth,2)-1
   news=zeros(nmonth,k)
 
   if ind == 0 then
      if dropna then
         for i=1:nmonth
            sr=s(changmonth(i):changmonth(i+1)-1,:)
            findnonna=or(~isnan(sr),'c')
            news(i,:)=mean0(sr(findnonna,:),1)
         end
      else
         for i=1:nmonth
            news(i,:)=mean0(s(changmonth(i):changmonth(i+1)-1,:),1)
         end
      end
   else
      if dropna then
         for i=1:nmonth
            sr=s(changmonth(i):changmonth(i+1)-1,:)
            findnonna=or(~isnan(sr),'c')
            news(i,:)=sum(sr(findnonna,:),1)
         end
      else
         for i=1:nmonth
            news(i,:)=sum(s(changmonth(i):changmonth(i+1)-1,:),1)
         end
      end
   end
 
elseif ind >= 29 then
 
// search the last day of each month
   dvec=datevec(d)
   monthvec=dvec(:,2)
   dmonthvec=monthvec(2:$)-monthvec(1:$-1)
   changmonth=find(dmonthvec ~= 0)
   news=s(changmonth,:)
 
   if dropna then
      nanews=find(isnan(news(:,1)))
      newinds=changmonth
      indsuppr=0
      while ~isempty(nanews)
         newinds=newinds-1
         if newinds(1) < 1 then
            month=month+1
            news=news(2:$,:)
            newinds=newinds(2:$,:)
            nanews=nanews-1
            if nanews(1) < 1 then
               nanews(1)=[]
            end
         end
         news(nanews,:)=s(newinds(nanews),:)
         nanews=find(isnan(news(:,1)))
      end
   end
   dat0=year*12+month
   nmonth=size(news,1)
 
else
   dvec=datevec(d)
   monthvec=dvec(:,2)
   dayvec=dvec(:,3)
   inddvec=find(dayvec == ind)
   news=s(inddvec,:)
   month=monthvec(inddvec(1))
   dat0=date2num(year+'m'+string(month))
   nmonth=size(news,1)
 
end
if k==1 then
  ts=tlist(['ts';'freq';'dates';'series'],[12 1],[dat0:dat0+nmonth-1]',news)
else
  ts=tlist(['tsmat';'freq';'dates';'series';'names'],[12 1],[dat0:dat0+nmonth-1]',...
          news,ts('names'))
end
endfunction
