function [y,namey,grocer_prests,grocer_b,grocer_nonna,comments]=explone(grocer_ly,grocer_b,grocer_named,grocer_testna,grocer_dropna,grocer_mindat,grocer_lags)
 
// PURPOSE: explode several variables into matrices, names and
// define corresponding bounds
// ------------------------------------------------------------
// INPUT:
// * grocer_ly = list of variables:
//   each element could be
//   - a timeseries, a real vector,
//   a real matrix or a string (the name of a variable with
//   one of the types cited above, between quotes)
//   - a matrix of strings, each one being the name of a
//   variable
//   - the string 'cte' or 'const' if the user wants a constant
//     to be included automatically
// * grocer_b = a (p x 1) string vector (of dates) (optional:
//   if not given the function either takes the existing bounds
//   or determines the bounds suitable to the given series)
// * grocer_named = a (2 x 1) vector of strings representing the
//   name of variable not entered between quotes
//   (optional; default = ['endogenous' ; 'exogenous'])
// * grocer_testna = a boolean indicating whether the program
//   will test the existence of na’s values in the matrices of
//   values y
// * grocer_dropna = a boolean indicating whether the program
//   should keep only lines of matrices y and grocer_x
//   with non na values in both matrices (suppose that
//   grocer_testna has been set to %f)
// * grocer_mindat =
//   - %t if the user wants to take the min and max dates
//   over which any series exists
//   - %f if the user wants to take the time period over which
//   all series exist
// * grocer_lags = a (n x 1) vector, each coordinate indicating
//   the lag needed for the corresponding elements in the list
//   grocer_vars
// ------------------------------------------------------------
// OUTPUT:
// * y = a (T x ky) real vector or a ts
// * namey = a (ky x 1) string vector
// * prests = a boolean indicating whether there is a ts
// * grocer_b = a (2 x 1) string matrix (of dates) or []
// * grocer_nonna = a (T x 1) vector indicating the indexes of
//   non NA observations
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2022
// http://grocer.toolbox.free.fr/grocer.html
 
 
[grocer_nargout,grocer_nargin] = argn(0)
if grocer_nargin < 7 then
   grocer_lags=0
end
if grocer_nargin < 6 then
   grocer_mindat=%f
end
if grocer_nargin < 5 then
   grocer_dropna=%f
end
if grocer_nargin < 4 then
   grocer_testna=%t
end
if grocer_nargin < 3 then
   grocer_named='variable'
end
if grocer_nargin < 2 then
   grocer_b = []
end
grocer_prests=%f
 
 
// explode the list of variables into its various components (real matrices, ts, tsmat, specific variables)
// and their indexes
[namey,listtsy,vecy,indtsy,indvecy,indctey,ny,listtsmaty,indtsmaty,comments]=...
   explovars(grocer_ly,grocer_named)
 
if ~isempty(indtsy) then
   ts1=listtsy(1)
   fq=ts1('freq')
elseif ~isempty(indtsmaty) then
   tsmat1=listtsmaty(1)
   fq=tsmat1('freq')
end

for i=1:length(listtsy) 
    tsi=listtsy(i)
    fqi=tsi('freq')
    if fqi(1) ~= fq(1) | cumprod(fq) ~= cumprod(fqi) then
       error('ts have not the same frequency')
    end
end      
 
for i=1:length(listtsmaty)
    tsmati=listtsmaty(i)
    fqi=tsmati('freq')
    if fqi(1) ~= fq(1) | cumprod(fq) ~= cumprod(fqi) then
       error('ts or tsmat have not the same frequency')
    end
end      
 
grocer_prests = (length(listtsy) ~= 0 | length(listtsmaty) ~= 0) | grocer_prests
grocer_searchb=%f
 
isvec = (size(vecy,1) ~= 0)
grocer_b0=grocer_b
boundsnum=[]
 
if grocer_prests then
   if isvec then
      warning('your regression contains ts as well as vectors')
   end
 
   if isempty(grocer_b) then
      if exists('grocer_boundsvar') then
         if ~isempty(grocer_boundsvar) then
            [junk,fqb]=date2num_fq(grocer_boundsvar(1))
            if fqb(1) ~= fq(1) | cumprod(fq) ~= cumprod(fqb) then
               error('time series and bounds have not the same frequency')
            end
            grocer_b=grocer_boundsvar
         else
            grocer_searchb=%t
         end
      else
         grocer_searchb=%t
      end
   end
 
   if grocer_searchb then
      dates_start=[]
      dates_end=[]
      if ~isempty(listtsy) then
         [datei_start,datei_end]=ts_span(listtsy)
         dates_start=[dates_start ; datei_start+grocer_lags]
         dates_end=[dates_end ; datei_end]
      end
      if ~isempty(listtsmaty) then
         [datei_start,datei_end]=ts_span(listtsmaty)
         dates_start=[dates_start ; datei_start+grocer_lags]
         dates_end=[dates_end ; datei_end]
      end
      if ~grocer_testna & grocer_mindat then
         dmin=min(dates_start)
         dmax=max(dates_end)
         boundsnum=[dmin:dmax]'
      else
         dmin=max(dates_start)
         dmax=min(dates_end)
      end
      boundsnum=[dmin:dmax]'
      grocer_b=[num2date(dmin,fq) ; num2date(dmax,fq)]
 
   else
      boundsnum=[date2num(grocer_b(1)):date2num(grocer_b(2))]'
      for i=2:size(grocer_b,1)/2
         boundsnum=[boundsnum ; [date2num(grocer_b(2*i-1)):date2num(grocer_b(2*i))]']
      end
 
   end
   nobs=size(boundsnum,1)
 
   nmaty=size(vecy,1) // number of observations stemming from the real matrices
   if nmaty > 0 & nmaty ~= nobs then
      error('nobs of matrices do not match with those of ts')
   end
 
   y=%nan*ones(nobs+grocer_lags,ny) // y = vector of values to fill
   b1=[boundsnum(1)-[grocer_lags:-1:0]' ;boundsnum(2:$)]
 
   for k=1:size(indtsy,1)
      tsk=listtsy(k)
      tsk_dates=tsk('dates')
 
      if tsk_dates(1)-b1(1) > 0 & grocer_testna then
         error('series '+namey(indtsy(k))+' starts after the bounds you have given')
      end
      if b1($)-tsk_dates($) > 0 & grocer_testna then
         error('series '+namey(indtsy(k))+' ends before the bounds you have given')
      end
 
      start_y=max(1,tsk_dates(1)-b1(1)+1)
      end_y=min(nobs,nobs-b1($)+tsk_dates($))+grocer_lags
      by=b1(b1 >= tsk_dates(1) & b1 <= tsk_dates($))
      if ~isempty(by) then
         y(start_y:end_y,indtsy(k))=tsk('series')(by-tsk_dates(1)+1) // fill the values stemming from ts
      end
   end
 
   ind0=0
   for k=1:length(listtsmaty)
      tsmatk=listtsmaty(k)
      tsmatk_dates=tsmatk('dates')
 
      if tsmatk_dates(1)-b1(1) > 0 & grocer_testna then
         error('tsmat input starts after the bounds you have given')
      end
      if b1($)-tsmatk_dates($) > 0 & grocer_testna then
         error('tsmat input ends before the bounds you have given')
      end
      if size(tsmatk_dates,1) ~= size(tsmatk('series'),1) then
         error('dimensions of dates ('+string(size(tsmatk_dates,1))+'rows) and series ('+string(size(tsmatk('series'),1))+'rows) in tsmat #'+ string(k)+'do not match')
      end
 
      start_y=max(1,tsmatk_dates(1)-b1(1)+1)
      end_y=min(nobs,nobs-b1($)+tsmatk_dates($))+grocer_lags
      by=b1(b1 >= tsmatk_dates(1) & b1 <= tsmatk_dates($))
      ind1=size(tsmatk('series'),2)
      y(start_y:end_y,indtsmaty(ind0+[1:ind1]))=tsmatk('series')(by-tsmatk_dates(1)+1,:) // fill the values stemming from ts
      ind0=ind1
   end
 
else
// there is no ts: only real matrices and specific objects
   if isempty(indvecy) & ~isempty(indctey) then
      if exists('grocer_boundsvarnum') then
         nobs=sum(grocer_boundsvarnum(2:2:$)-grocer_boundsvarnum(1:2:$-1)+1)
      else
         error('if list of variables contain only specific values, such as const, trend^p, then you need to define bounds')
      end
   else
      nobs=size(vecy,1)
   end
   y=ones(nobs,ny)
 
end
 
y(:,indvecy)=vecy // fill the concerned yj columns with their values
 
for i=1:size(indctey,1)
   k=indctey(i)
   y=deal_varspec(y,namey(k),k,boundsnum) // fill specific variables
end
 
grocer_mat_aux=[y , mlag(y,grocer_lags)]
grocer_mat=grocer_mat_aux(1+grocer_lags:$,:)
grocer_nonna=find(and(~isnan(grocer_mat),'c'))
if grocer_dropna then
   y=y(grocer_nonna,:)
 
elseif grocer_searchb & grocer_testna then
   boundsnum=[dmin:dmax]'
   [indminb,indmaxb]=longest_nonna_span(grocer_mat,'c')
   boundsnum=boundsnum(indminb:indmaxb)
   grocer_b=[num2date(boundsnum(1),fq) ; num2date(boundsnum($),fq)]
   y=y(indminb:indmaxb+grocer_lags,:)
 
elseif grocer_testna then
   presna=find(or(isnan(y),'r'))
   if ~isempty(presna) then
      error('series '+strcat(namey(presna),', ')+' contain(s) Nan in the range you have specified')
   end
 
end
 
endfunction
 
