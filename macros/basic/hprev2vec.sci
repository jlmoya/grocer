function [grocer_n0,grocer_nf,grocer_hprev]=hprev2vec(grocer_res,grocer_hprev)
 
// PURPOSE: transforms the entry pertaining to the horizon of
// a forecast into a vector containing the respective places
// of the start and the end of the forecast relative to the
// index of the end of the estimation period
// ------------------------------------------------------------
// INPUT:
// * grocer_res = a tlist result from an estimation (var,
//   varma, ms)
// * grocer_hprev = the prevision period which can be either
//   . a [n1 n2] constant vector where n1 and n2 are the lead
//     over the last period of the estimation (n1<=0 means that
//     the forecast begins within the estimation period)
//   . a n constant which is equivalent to [1 n] (forecast
//     begins just after the estimation period)
//   . a [n1 n2] string vector where n1 and n2 are the time
//     periods for forecasting (a posibility open only if the
//     model has been estimated on ts)
//   . a n string which is equivalent to [1 n] (forecast
//     begins just after the estimation period)
// ------------------------------------------------------------
// OUTPUT:
// * grocer_n0 = the index of the start of the forecast,
//   relative to the index of the end of the estimation
// * grocer_nf = the index of the end of the forecast,
//   relative to the index of the end of the estimation
// * grocer_hprev =
//   - if there are ts in the estimation, the time bounds of
//     the forecast
//   - if there is no ts in the estimation, the original
//     variable (useless in that case)
// ------------------------------------------------------------
 
grocer_prests=grocer_res('prests')
// calculate the range for forecasting
select typeof(grocer_hprev)
 
case 'constant'
   [grocer_nl,grocer_nc]=size(grocer_hprev)
   if grocer_nl == 1 & grocer_nc == 1 then
      grocer_nf=grocer_hprev
      grocer_n0=1
      grocer_hprev=[1 ;  grocer_hprev]
 
   elseif grocer_nc ~= 1  & grocer_nl ~= 1 then
      error('arg # 2 should be a vector or a constant')
 
   elseif max(grocer_nc,grocer_nl) ~= 2 then
      error('arg # 2 should be a (2 x 1) or a (1 x 2) vector or a constant')
 
   else
      grocer_n0=grocer_hprev(1)
      grocer_nf=grocer_hprev(2)
   end
 
   if grocer_prests then
   // calculate hprev as a matrix of dates
      grocer_b=grocer_res('bounds')
      grocer_bf=grocer_b(max(size(grocer_b)))
      grocer_fq=date2fq(grocer_bf)
      grocer_hprev=[num2date(date2num(grocer_bf)+grocer_n0,grocer_fq) ;...
             num2date(date2num(grocer_bf)+grocer_nf,grocer_fq) ]
   end
 
case 'string' then
   [grocer_nl,grocer_nc]=size(grocer_hprev)
 
   if ~grocer_prests then
      error('your '+grocer_res('meth')+' model has not been estimated on ts')
 
   elseif grocer_nc ~= 1  & grocer_nl ~= 1 then
       error('arg # 2 should be a string vector or a string')
 
   elseif grocer_nl == 1 & grocer_nc == 1 then
      grocer_n0=1
      grocer_b=grocer_res('bounds')
      grocer_bf=grocer_b($)
      grocer_nf=diff_date(grocer_hprev,grocer_bf)
      grocer_fq=date2fq(grocer_bf)
      grocer_hprev=[num2date(date2num(grocer_bf)+1,grocer_fq) ; grocer_hprev]
 
   else
      grocer_b=grocer_res('bounds')
      grocer_bf=grocer_b($)
      grocer_fq=date2fq(grocer_bf)
      grocer_n0=diff_date(grocer_hprev(1),grocer_bf)
      grocer_nf=diff_date(grocer_hprev(2),grocer_bf)
   end
 
else
   error(typeof(grocer_hprev)+' is not a valid type for arg # 2')
end
 
endfunction
 
