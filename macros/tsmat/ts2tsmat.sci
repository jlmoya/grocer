function tsmat=ts2tsmat(varargin)
 
// PURPOSE: transform n ts in a tsmat
// ------------------------------------------------------------
// INPUT:
// * varargin = time series, the string 'cte' or 'const'
//   vectors or matrices that have the same # of rows, itself
//   equal to the # of time periods matched by the ts
// ------------------------------------------------------------
// OUTPUT:
// * tsmat= a tlist of type tsmat
// ------------------------------------------------------------
// Copyright: Eric Dubois 2008-2019
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
grocer_testna=%f
grocer_dropna=%f
grocer_comments=%f
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if or(['testna';'dropna'] == grocer_argi) then
         execstr('grocer_'+part(grocer_argi,1:6)+'=%t')
         varargin(grocer_i)=null()
 
      elseif grocer_argi == 'comments' then
         grocer_comments=%t
         varargin(grocer_i)=null()
 
      end
   end
end
 
if ~exists('grocer_boundsvar') then
   grocer_boundsvar=[]
end
 
[grocer_namey,grocer_listtsy,grocer_vecy,grocer_indtsy,grocer_indvecy,grocer_indctey,grocer_ny]=...
explovars(varargin,'ts')
grocer_prests=(length(grocer_listtsy) ~= 0)
 
if grocer_prests then
   if grocer_vecy ~= [] then
      warning('your data contain vectors')
   end
 
   ntsy=size(grocer_indtsy,1)
 
   if ~isempty(grocer_boundsvar) then
      if ~grocer_testna then
         b1=date2num(grocer_boundsvar(1))
         b2=date2num(grocer_boundsvar($))
         grocer_y=%nan*ones(b2-b1+1,grocer_ny)
         for grocer_i=1:size(grocer_indtsy,1)
            tsi=grocer_listtsy(grocer_i)
            datesi=tsi('dates')
            tsi=tsi('series')
            grocer_y(:,grocer_indtsy(grocer_i))=tsi(datesi(1)-b1+1:(b2-b1)+1)
         end
      end
   else
      if grocer_dropna then
         [grocer_yts,grocer_boundsvar,grocer_junk,grocer_comm]=explots(grocer_listtsy,%f,%f)
      else
         [grocer_yts,grocer_boundsvar,grocer_junk,grocer_comm]=explots(grocer_listtsy,%f,%t)
      end
 
      b1=date2num(grocer_boundsvar(1))
      b2=date2num(grocer_boundsvar($))
      nobs=size(grocer_yts,1)
      grocer_y=ones(nobs,grocer_ny)
      grocer_y(:,grocer_indtsy)=grocer_yts
   end
   grocer_y(:,grocer_indvecy)=grocer_vecy
   grocer_y(:,grocer_indctey)=1
 
 
else
   error('you should have at least one ts in your data')
 
end
 
grocer_nonna=find(and(~isnan(grocer_y),'c'))
if grocer_testna then
 
   grocer_presna=find(or(isnan(grocer_y),'r'))
   for i=1:size(grocer_presna,2)
      error('series '+grocer_namey(grocer_presna(i))+' contains Nan in the range you have specified')
   end
 
end
if grocer_comments then
   tsmat=tlist(['tsmat';'freq';'dates';'series';'names';'comments'],date2fq(grocer_boundsvar(1)),[b1:b2]',grocer_y,grocer_namey,grocer_comm)
else
   tsmat=tlist(['tsmat';'freq';'dates';'series';'names'],date2fq(grocer_boundsvar(1)),[b1:b2]',grocer_y,grocer_namey)
end
 
endfunction
 
