function [p]=dynfore(grocer_res,grocer_endo,grocer_bounds)
 
// PURPOSE: provides a dynamic forecast from an equation
// estimated by ols(), hwhite(), olst(), lad(),...
// ------------------------------------------------------------
// INPUT:
// * grocer_res = result tlist
// * grocer_endo = a string, the name of the endogenous
//  variable
// * grocer_bounds = the bounds over which to perform the
//   simulation
// ------------------------------------------------------------
// OUTPUT:
// p = forecast
// ------------------------------------------------------------
// NOTES:
// * can be used also with results of olsc (but does not take
//   into account the correlation)
// * cannot be used with results of garch (but this needs only
//   small adaptation)
// * only works with ts
// * the data miust be available in the calling environment
//   (the result tlist is not sufficient)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
[nargout,nargin]=argn(0)
 
// transform dates in their numerical represntation
[grocer_d1,grocer_fq]=date2num_fq(grocer_bounds(1))
grocer_d2=date2num(grocer_bounds(2))
execstr('grocer_d0='+grocer_endo+'(''dates'')')
grocer_d0=grocer_d0(1)
// take the endogenous variable only over the period before simulation
execstr(grocer_endo+'=subper('+grocer_endo+','''+num2date(grocer_d0,grocer_fq)...
+''','''+num2date(grocer_d1-1,grocer_fq)+''')')
execstr('grocer_s=['+grocer_endo+'(''series'');zeros(grocer_d2-grocer_d1+1,1)]')
execstr(grocer_endo+'(''dates'')=[grocer_d0:grocer_d2]''')
execstr(grocer_endo+'(''series'')=grocer_s')
grocer_b=grocer_res('bounds')
 
if grocer_res('meth') == 'DMA' then
   grocer_diff=grocer_d1-[date2num(grocer_b(1)) ; date2num(grocer_b($))]
   if grocer_diff(1) < 0 then
      error('starting forecast period before start of DMA estimation')
   else
      grocer_theta=grocer_res('exp theta')
      grocer_beta=grocer_theta($+min(0,grocer_diff(2)),:)'
      grocer_namex=[grocer_res('fixed namex') ; grocer_res('variable namex')]
   end
 
else
   grocer_beta=grocer_res('beta')
   grocer_namex=grocer_res('namex')
 
end
grocer_namey=strsubst(grocer_res('namey'),' ','')
 
// replace the constant term, if any, by 1 and define the trends, if any,
// on the simulation period
grocer_namex(find(grocer_namex=='cte'))='1'
grocer_namex(find(grocer_namex=='const'))='1'
grocer_daten=[grocer_d1:grocer_d2]'
grocer_trend=tlist(['ts';'freq';'dates';'series'],grocer_fq,grocer_daten,...
                      grocer_daten-date2num(grocer_b(1))+1)
grocer_indtrend=find(grocer_namex == 'trend')
grocer_indtrendp=find(part(strsubst(grocer_namex,' ',''),1:6) == 'trend^')
if ~isempty(grocer_indtrend) then
   grocer_namex(grocer_indtrend)='grocer_trend'
end
if ~isempty(grocer_indtrendp)
   grocer_namex(grocer_indtrendp)=strsubst(grocer_namex(grocer_indtrendp),'trend^','grocer_trend^')
end
 
 
grocer_nvar=size(grocer_namex,1)
grocer_niter=0
load(GROCERDIR+'/data/functions.dat')
 
grocer_start_simulate=''
grocer_end_simulate='grocer_beta('+string(grocer_nvar)+')*('+grocer_namex(grocer_nvar)+'))'
for grocer_j=grocer_nvar-1:-1:1
   grocer_end_simulate='grocer_beta('+string(grocer_j)+')*('+grocer_namex(grocer_j)+')+'+grocer_end_simulate
end
grocer_end_simulate='('+grocer_end_simulate
 
grocer_ncharendo=length(grocer_endo)
while part(grocer_namey,1:grocer_ncharendo) ~= grocer_endo & grocer_niter < 20 then
   grocer_niter=grocer_niter+1
   if part(grocer_namey,1:6) == 'delts(' then
      [grocer_x,grocer_n,grocer_end]=delts2xandn(grocer_namey)
      grocer_namey=grocer_x+'-lagts('+grocer_n+grocer_x+')'+grocer_end
 
   elseif part(grocer_namey,1:8) == 'growthr(' then
      [grocer_firstpart,grocer_ind_strout]=find_end_expr(grocer_namey,strindex(grocer_namey,'('))
      grocer_start_simulate='('+grocer_start_simulate
      grocer_endnamey=part(grocer_namey,grocer_ind_strout(2)+2:length(grocer_namey))
      grocer_end_simulate=deal_endnamey(grocer_endnamey,grocer_end_simulate)
      grocer_end_simulate=grocer_end_simulate+'+1)*lagts('+grocer_firstpart+')'
      grocer_namey=grocer_firstpart
 
   else
      for grocer_i=1:size(grocer_func,1)
         if grocer_func(grocer_i)+'(' == part(grocer_namey,1:length(grocer_func(grocer_i))+1) then
            [grocer_firstpart,grocer_ind_strout]=find_end_expr(grocer_namey,strindex(grocer_namey,'('))
            grocer_start_simulate=grocer_invfunc(grocer_i)+'('+grocer_start_simulate
            grocer_endnamey=part(grocer_namey,grocer_ind_strout(2)+2:length(grocer_namey))
            grocer_namey=grocer_firstpart
 
            grocer_end_simulate=deal_endnamey(grocer_endnamey,grocer_end_simulate)+')'
         end
      end
   end
end
 
if part(grocer_namey,1:grocer_ncharendo) == grocer_endo then
   grocer_endnamey=part(grocer_namey,grocer_ncharendo+1:length(grocer_namey))
   grocer_end_simulate=deal_endnamey(grocer_endnamey,grocer_end_simulate)
 
else
    write(%io(2,'(a)'),'error in dynfore: the name of the endogenous variable in the list does not begin with '+...
    grocer_endo+' or delts('+grocer_endo)
    abort
 
end
grocer_simulate=grocer_endo+'(''series'')(grocer_i)=values('+grocer_start_simulate+grocer_end_simulate+',grocer_dat)'
 
 
for grocer_datnum=grocer_d1:grocer_d2
   grocer_dat=num2date(grocer_datnum,grocer_fq)
   grocer_i=grocer_datnum-grocer_d0+1
   execstr(grocer_simulate)
end
p=subper(evstr(grocer_endo),grocer_bounds)
 
endfunction
