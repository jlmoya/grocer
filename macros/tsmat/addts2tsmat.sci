function grocer_tsmat=addts2tsmat(grocer_tsmat,grocer_names)
 
// PURPOSE: add timeseries to a tsmat
// ------------------------------------------------------------
// INPUT:
// * grocer_tsmat = a tsmat
// * grocer_names =  a string vector, collecting the names of
//   the ts to add to the tsmat
// ------------------------------------------------------------
// OUTPUT:
// * grocer_tsmat = the original tsmat extended with the new ts
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2016 / Emmanuel Michaux 2008
// http://grocer.toolbox.free.fr/grocer.html
 
if typeof(grocer_tsmat) ~= 'tsmat' then
   error('arg # 1 shoud be a tsmat')
end
 
if typeof(grocer_names) ~= 'string' then
   error('arg # 2 shoud be a string or a string vector')
end
 
grocer_s=grocer_tsmat('series')
grocer_fq=grocer_tsmat('freq')
grocer_dattsmat=grocer_tsmat('dates')
grocer_dat1=grocer_dattsmat(1)
grocer_dat$=grocer_dattsmat($)
grocer_ndates=size(grocer_dattsmat,1)
grocer_namestsmat=grocer_tsmat('names')
 
grocer_nts=size(grocer_names,'*')
grocer_ntsmat=size(grocer_namestsmat,'*')
if or(grocer_tsmat(1) == 'comments') then
   grocer_iscomm=%t
   grocer_comments=[grocer_tsmat('comments') ; emptystr(grocer_nts,1)]
 
else
   grocer_iscomm=%f
end
 
grocer_s2=%nan*zeros(grocer_ndates,grocer_nts)
for grocer_i=1:grocer_nts
   grocer_tsi=evstr(grocer_names(grocer_i))
   grocer_freqi=grocer_tsi('freq')
   if grocer_freqi ~= grocer_fq then
      error('freq of ts '+grocer_names(grocer_i)+'('+string(grocer_freqi)+') does not match with freq of tsmat')
   end
   grocer_dati=grocer_tsi('dates')
   grocer_si=grocer_tsi('series')
   grocer_starti=grocer_dati(1)
   grocer_endi=grocer_dati($)
 
   if grocer_starti > grocer_dat1 | grocer_endi > grocer_dat$ then
      warning('ts '+grocer_names(grocer_i)+' is shorter than tsmat: missing values set to nan')
   end
 
   if or(grocer_tsi(1) == 'comment') then
      if ~grocer_iscomm then
        grocer_comments=emptystr(grocer_ntsmat+grocer_nts,1)
      end
      grocer_comments(grocer_ntsmat+grocer_i)=grocer_tsi('comment')
   end
 
 
   grocer_indtsmat1=max(1,grocer_starti-grocer_dat1+1)
   grocer_indts1=max(1,grocer_dat1-grocer_starti+1)
   grocer_indtsmat$=min(grocer_ndates,grocer_endi-grocer_dat$+grocer_ndates)
   grocer_indts$=grocer_endi-grocer_starti+1-max(0,grocer_endi-grocer_dat$)
   grocer_s2(grocer_indtsmat1:grocer_indtsmat$,grocer_i)=grocer_si(grocer_indts1:grocer_indts$)
end
grocer_tsmat('series')=[grocer_s , grocer_s2]
grocer_tsmat('names')=[grocer_namestsmat ; grocer_names(:)]
if grocer_iscomm then
   grocer_tsmat('comments')=grocer_comments
end
 
endfunction
