function tsmat=tsmat_extrap(tsmat,varargin)
 
// PURPOSE: extrapolates variables of a tsmat
// ------------------------------------------------------------
// INPUT:
// * tsmat = a tsmat
// * varargin = N sequences variable,bounds,type_extrap,values
//   with:
//   - variable = a string, the names of a variable in the
//     tsmat that will be extrapolated
//   - bounds = the bounds over which the extrapolation is
//     made
//   - type_extrap = a string, the way the extrapolation will
//     be made ('level' if it is done by entering its values ;
//     'growth rate' if it is done by applying growth rate to
//     the previous value, 'delta rate' if it is done by
//     adding values to the previous one, and 'av growth rate'
//     if it is done by applying the average growth rate on the
//     past n previous dates,   'av growth rate' is like
//     'growth rate' but with the average growth rate calculated
//     on the last n periods ; 'series' together with the name of a series
//     in the tsmat applies the growth rates of the reference series
//     to the extrapolated one, over the chosen time lapse)
//   - values = either a scalar or a vector of the size of the
//     bounds, providing the value(s) used for extrapolation
// ------------------------------------------------------------
// OUTPUT:
// * tsmat = the original tsmat with the given variables
//   extrapolated
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018-2019
// Tom Coral 2019
// http://grocer.toolbox.free.fr/grocer.html
 
nargin=length(varargin);
tsmat_dates=tsmat('dates')    ;
tsmat_series=tsmat('series') ;
tsmat_names=tsmat('names') ;
[nobs,nsers]=size(tsmat_series)   ;
tsmat_freq=tsmat('freq')  ;
 
datenum_$0=tsmat_dates($);
datenum_$=datenum_$0;
for i=2:4:nargin-2
    dates_i=varargin(i);
    [datnum_i1,fq_i1]=date2num_fq(dates_i(1));
    if cumprod(fq_i1) ~= cumprod(tsmat_freq) | fq_i1(1) ~= tsmat_freq then
       error(dates_i(1)+' has not the same frequency ('+string(fq_i1)+') as the tsmat ('+ string(tsmat_freq)+')');
    end
    if size(dates_i,'*') == 2 then
       [datnum_i2,fq_i2]=date2num_fq(dates_i(2));
       if fq_i2 ~= tsmat_freq then
          error(dates_i(1)+' has not the same frequency ('+string(fq_i2)+') as the tsmat ('+ string(tsmat_freq)+')');
        end
    else
       datnum_i2=datnum_i1
       varargin(i)=[dates_i;dates_i]
    end
    if datnum_i1 > datenum_$0+1 then
       error(dates_i(1)+' is more than one period later than the last date of the tsmat');
    end
    datenum_$=max(datenum_$,datnum_i2);
end
dates_new=[tsmat_dates(1):datenum_$]';
series_new=[tsmat_series ; %nan*ones(datenum_$-tsmat_dates($),nsers)];
 
for i=1:4:nargin-2
   name_i=varargin(i)
   dates_i=varargin(i+1)
   proj_i=varargin(i+3)
 
   ind_i=find(tsmat_names == name_i)
   if isempty(ind_i) then
      warning('variable '+name_i+' not found in the database and cannot be extrapolated')
   end
   ind_dat1=date2num(dates_i(1))-tsmat_dates(1)+1
   ind_dat2=date2num(dates_i(2))-tsmat_dates(1)+1
   ndates=ind_dat2-ind_dat1+1
 
   nvals=size(proj_i,'*')
   if nvals == 1 & typeof(proj_i) ~= 'string' then
      proj_i=proj_i*ones(ndates,1)
   end
 
   select varargin(i+2)
 
   case 'level' then
       series_new(ind_dat1:ind_dat2,ind_i)=proj_i
 
   case 'growth rate' then
       series_new(ind_dat1:ind_dat2,ind_i)=cumprod(1+proj_i)*series_new(ind_dat1-1,ind_i)
 
   case 'delta rate' then
       series_new(ind_dat1:ind_dat2,ind_i)=cumsum( proj_i)+series_new(ind_dat1-1,ind_i)
 
   case 'av growth rate' then
       av_growth=(tsmat_series(ind_dat1-1,ind_i)/tsmat_series(ind_dat1-proj_i(1)-1,ind_i))^(1/proj_i(1))
       series_new(ind_dat1:ind_dat2,ind_i)=series_new(ind_dat1-1,ind_i)*av_growth^(1:ndates)'
 
    case 'series' then
       ref_i=find(tsmat.names==varargin(i+3))
       series_new(ind_dat1:ind_dat2,ind_i)=series_new(ind_dat1:ind_dat2,ref_i)*series_new(ind_dat1-1,ind_i)/series_new(ind_dat1-1,ref_i)
 
   else
       error('not an available option:' +string(varargin(i+2)))
   end
end
 
tsmat('series')=series_new
tsmat('dates')=dates_new
 
 
endfunction
