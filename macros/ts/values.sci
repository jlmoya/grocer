function val=values(ts,dat,namets)
 
// PURPOSE: give the value of a timeseries for a given date
// ------------------------------------------------------------
// INPUT:
// * ts = a timeseries or a tsmat
// * dat = a date string
// * namets = the name of a ts, if first arg is a tsmat
// ------------------------------------------------------------
// OUTPUT:
// * val = the value of a timeseries for the given date
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2023 / Emmanuel Michaux 2008
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
ndat=size(dat,'*')
type_dat=typeof(ts)
 
if type_dat == 'ts' | nargin == 2 then
   ts_dat=ts('dates')
   if ndat == 1 then
      num_dat=date2num(dat)
      if num_dat < ts_dat(1) | num_dat > ts_dat($) then
         error(string(dat)+' is not in the range of the '+type_dat)
      end
      val=ts('series')(num_dat-ts_dat(1)+1,:)

   elseif ndat == 2 then
      num_dat1=date2num(dat(1))
      num_dat2=date2num(dat(2))
      if num_dat1 < ts_dat(1) | num_dat2 > ts_dat($) then
         error(string(dat(1))+':'+string(dat(2))+' is not in the range of the ts')
      end
      val=ts('series')([num_dat1:num_dat2]-ts_dat(1)+1,:)
      
   else
      error('too many dates in arg #2')

   end
 
elseif type_dat == 'tsmat'
   ts_dat=ts('dates')
   ind_ts=find(ts('names') == namets)
   if ndat == 1 then
      num_dat=date2num(dat)
      if num_dat < ts_dat(1) | num_dat > ts_dat($) then
         error(string(dat)+' is not in the range of the ts'+type_dat)
      end   
      val=ts('series')(num_dat-ts('dates')(1)+1,ind_ts)

   elseif ndat == 2 then
      num_dat1=date2num(dat(1))
      num_dat2=date2num(dat(2))
      if num_dat1 < ts_dat(1) | num_dat2 > ts_dat($) then
         error(string(dat(1))+':'+string(dat(2))+' is not in the range of the ts')
      end
      val=ts('series')([num_dat1:num_dat2]-ts('dates')(1)+1,ind_ts)

   else
      error('too many dates in arg #2')

   end
 
elseif and(type_dat ~= ['ts';'tsmat']) then
   error('not an admissible type for first arg: '+type_dat)
 
end
 
endfunction
