function ts=da2q(ts,ind,dropna)
 
// PURPOSE: transforms daily data into monthly ones
// ------------------------------------------------------------
// INPUT:
// * ts = a daily timeseries
// * ind =
//   - -1 if the quarterly data is to be the sum of the
// corresponding days
//   - 0 if the  quarterly data is to be the mean of the
// corresponding days
//   - n between 1 and 90 if the quarterly data is to be the
//     value of the n-th day of the month
//   - n > 90 if the quarterly data is to be the value of the
//     last day of the quarter
// ind is optional; if not provided, it is set to -1
// * dropna = 'dropna' if the user wants to withdraw all NA
//   values from the calculations (case ind=0 or -1) or to take
//   the last non NA value of the quarter (case ind > 90)
// if not entered then all NA values are considered
// ------------------------------------------------------------
// OUTPUT:
// * ts = the corresponding quarterly time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007-2016
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
// retrieve the first day of the full quarter
// and its index in the vectors series, listna or dates
// calculate the number of full years
// and transform the listna and series in order
// to have the 4 quarterly values of one year
// on the rows of the matrix mtrans and natrans
// set div to 1 if ind=-1, to 4 if ind=0
 
   if day == 1 & modulo(month,3) == 1 then
      ind_start=1
      month_start=month
      q_start=floor((month-1)/3)+1
 
   else
      day_start=1
      if month >= 11 | (month == 10 & day > 1) then
         year_start=year+1
         month_start=1
         q_start=1
 
      else
         q_start=floor((month-1)/3)+2
         month_start=q_start*3-2
         year_start=year
      end
 
      ind_start=datenum(year_start,month_start,day_start)-d(1)+1
 
   end
   dat0=year*4+q_start
 
   dat=num2date(d($)+1,365)
   execstr('year='+part(dat,1:indsep(1)-1))
   execstr('month='+part(dat,indsep(1)+1:indsep(2)-1))
   execstr('day='+part(dat,indsep(2)+1:length(dat)))
 
   if day == 1 & modulo(month,3) == 1 then
      // this means that the last period was the end of the quarter
      ind_end=size(d,1)
   else
      ind_end=datenum(year,floor((month-1)/3)*3+1,1)-d(1)
   end
 
   s=s(ind_start:ind_end,:)
   d=d(ind_start:ind_end,:)
   dvec=datevec(d)
   trimvec=floor((dvec(:,2)-1)/3)+1
   dtrimvec=trimvec(2:$)-trimvec(1:$-1)
   ind_nonzero=find(dtrimvec ~= 0)
   if isempty(ind_nonzero) then
      changt=[1 ind_end-ind_start+2]
   else
      changt=[1 find(dtrimvec ~= 0)+1 ind_end-ind_start+2]
   end
   ntrim=size(changt,2)-1
   news=zeros(ntrim,k)
 
   if ind == 0 then
      if dropna then
         for i=1:ntrim
            sr=s(changt(i):changt(i+1)-1,:)
            findnonna=or(~isnan(sr),'c')
            news(i,:)=mean0(sr(findnonna,:),1)
         end
      else
         for i=1:ntrim
            news(i,:)=mean0(s(changt(i):changt(i+1)-1,:),1)
         end
      end
   else
      if dropna then
         for i=1:ntrim
            sr=s(changt(i):changt(i+1)-1,:)
            findnonna=or(~isnan(sr),'c')
            news(i,:)=sum(sr(findnonna,:),1)
         end
      else
         for i=1:ntrim
            news(i,:)=sum(s(changt(i):changt(i+1)-1),1)
         end
      end
   end
 
elseif ind >= 91 then
 
// search the last day of each month
   dvec=datevec(d)
   monthvec=dvec(:,2)
   dmonthvec=monthvec(2:$)-monthvec(1:$-1)
   changtrim=find((dmonthvec ~= 0) & (modulo(monthvec(2:$),3) == 1))
   q0=monthvec(changtrim(1))/3
   news=s(changtrim,:)
 
   if dropna then
      nanews=find(isnan(news(:,1)))
      newinds=changtrim
      indsuppr=0
      while ~isempty(nanews)
         newinds=newinds-1
         if newinds(1) < 1 then
            q0=q0+1
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
   dat0=date2num(year+'q'+string(q0))
   ntrim=size(news,1)
 
else
 
   dvec=datevec(d)
   monthvec=dvec(:,2)
   dmonthvec=monthvec(2:$)-monthvec(1:$-1)
   changtrim=find((dmonthvec ~= 0) & (modulo(monthvec(2:$),3) == 1))
   q0=modulo(monthvec(changtrim(1))/3,4)+1
   inds=changtrim+ind
   month_inds1=modulo(monthvec(inds(1)),3)
   day_inds1=dvec(inds(1),3)
   month_1=modulo(monthvec(1),3)
   day_1=dvec(1,3)
   news=s(inds,:)
   if month_1 <= month_inds1 & day_1 <= day_inds1 then
      // the first quarter of the data contain also the day chosen
      inds=[datenum([dvec(1,1) dvec(1,2)-(month_1-1) 1 0 0 0])-d(1)+ind inds]
      q0=q0-1+4*(q0==1)
   end
   dat0=dvec(inds(1),1)*4+q0
   ntrim=size(inds,2)
   news=s(inds)
 
end
 
if k==1 then
  ts=tlist(['ts';'freq';'dates';'series'],[4 1],[dat0:dat0+ntrim-1]',news)
else
  ts=tlist(['tsmat';'freq';'dates';'series';'names'],[4 1],[dat0:dat0+ntrim-1]',...
            news,ts('names'))
end
 
endfunction
