function test_ts(ts)

// PURPOSE: makes several tests on ats to check if it has
// been correcytly designed
// ------------------------------------------------------------
// INPUT:
// * ts = a time series
// ------------------------------------------------------------
// OUTPUT:
// nothing: warning are displayed if a problem is recovered
// ------------------------------------------------------------
// Copyright Eric Dubois 2020
// http://grocer.toolbox.free.fr/grocer.html
    
if typeof(ts) ~= 'ts' then
   error('this is not a ''ts'' tlist')
end

if isempty(find(ts(1) == 'freq')) then
   warning('field ''freq'' is lacking')
end

if isempty(find(ts(1) == 'dates')) then
   warning('field ''dates'' is lacking')
end

if isempty(find(ts(1) == 'series')) then
   warning('field ''series'' is lacking')
end

dats=ts('dates')
if size(dats,2) > 1 then
   warning('field ''dates'' is not a column vector')
end

if size(ts('series'),2) > 1 then
   warning('field ''series'' is not a column vector')
end

del_dates=dats(2:$)-dats(1:$-1)
ind_leap=find(del_dates ~= 1)
if ~isempty(ind_leap) then
   warning('dates are not contiguous at indexes:')
   write(%io(2),ind_leap) 
end

endfunction
