function plt_etalcal(retal,bench)

// PURPOSE: plots the result of Insee's disaggragation method
// ------------------------------------------------------------
// INPUT:
// * retal = the results tlist from an Insee's disaggregation
//   method
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are plotted on a news graphing window
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux 2020
// http://grocer.toolbox.free.fr/grocer.html

if bench ~= 'no'
 
   yhat = retal('hf yhat')
   s= retal('high freq')
 
   ng=winsid()  // recover the list of open graphic w
   if isempty(ng) then
      ng=1
   else
      ng = ng(size(ng,2)) +1   // add 1 to the last open window
   end
   dat1=boundsvarb(1)
   dat2=boundsvarb(2)
   ind_infra1=strindex(dat1,slit);
   execstr('year1='+part(dat1,1:ind_infra1-1))
   ind_infra2=strindex(dat2,slit);
   execstr('year2='+part(dat2,1:ind_infra2-1))
   execstr('infra2='+part(dat2,ind_infra2+1))
   scal=[string([year1:year2-1] .*. ones(1,s(1)))+slit+string(ones(1,year2-year1) .*. [1:s(1)]) , string(year2)+slit+string([1:infra2])]
   y=%nan*zeros((year2-year1)*s(1)+infra2,2)
   if typeof(bench) == 'string' then
      execstr('bench='+bench)
   end
   d_bench=bench('dates')
   s_bench=bench('series')
   d_bench1=d_bench(1)
   d_bench2=d_bench($)
   if d_bench1 >= year1*s(1)+1 then
      ind_y1=d_bench1-year1*s(1)
      ind_bench1=1
   else
      ind_y1=1
      ind_bench1=year1*s(1)-d_bench1+1
   end
 
   if d_bench2 <= year2*s(1)+infra2 then
      ind_y2=d_bench2-year1*s(1)
      ind_bench2=d_bench2-d_bench1+1
   else
      ind_y2=size(y,1)
      ind_bench2=year2*s(1)+infra2-d_bench1+1
   end
 
   y(ind_y1:ind_y2,1)=s_bench(ind_bench1:ind_bench2)
   y(:,2)=yhat('series')
   pltseries0(y,[],'disaggregation of '+retal('namey'),scal,ng,'leg=[observed;disaggregated]','styleg=6')
end
  
endfunction
