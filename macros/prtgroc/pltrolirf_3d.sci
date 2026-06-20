function pltrolirf_3d(resrolirf,i,j,periods,horizons,foreground)
 
// PURPOSE: Plots the Impulse Response Function for rolling
// VAR
// ------------------------------------------------------------
// INPUT:
// * resrolirf = a results tlist returned by rolirf
// * i = the index of the variable whose response is plotted
// * j = the index of the shocked variable
// * varargin = optional arguments:
// * periods = the indexes of the first bound of the esttimation
//   periods that will be plotted
// * horizons = the indexes of the horizon of the irf
//-------------------------------------------------------------
// OUTPUT:
// nothing: only a graph is produced
//-------------------------------------------------------------
// Copyright E. Dubois (2014)
// http://grocer.toolbox.free.fr/grocer.html
 
 
nargin=argn(2)
 
rolirf_ij=resrolirf('ans_var'+string(j)+'_to_shock'+string(i))
rolirf_ij=rolirf_ij(periods,horizons)
[nper,hor]=size(rolirf_ij)
scf();
g=gcf()
colorm=ocean(24)
g.color_map=colorm(10:22,:)
 
if nargin < 6 then
   if nper < hor then
      foreground='horizons'
   else
      foreground='periods'
   end
end
 
resvar=resrolirf('rolling var results')
namey=resvar('namey')
 
select foreground
 
case 'periods' then
   surf(0:hor-1,0:nper-1,rolirf_ij(:,hor:-1:1),-rolirf_ij(:,hor:-1:1))
   ga=gca()
   gper=ga.y_label
   ghor=ga.x_label
 
case 'horizons' then
   surf(0:nper-1,0:hor-1,rolirf_ij(nper:-1:1,:)',-rolirf_ij(nper:-1:1,:)')
   ga=gca()
   gper=ga.x_label
   ghor=ga.y_label
 
end
ga.rotation_angles = [30,-30]
ga.font_size=3
 
if resvar('prests') then
   [bounds0,fq]=date2num_fq(resvar('start firstbound'))
   boundsn=date2num(resvar('end firstbound'))
   boundsper=bounds0:boundsn'
   boundspersel=boundsper(periods)
   ntics_per=min(nper,8)
   tics_per=1:ceil(nper/ntics_per):nper
   select foreground
   case 'periods' then
      ga.y_ticks=tlist(['ticks'  'locations'  'labels'],tics_per'-1,num2date(boundspersel(tics_per),fq)')
      if hor < 20 then
         ga.x_ticks=tlist(['ticks'  'locations'  'labels'],[0:hor-1]',string(hor-1:-1:0)')
      else
         ga.x_ticks(3)=ga.x_ticks(3)($:-1:1)
      end
   else
      ga.x_ticks=tlist(['ticks'  'locations'  'labels'],tics_per'-1,num2date(boundspersel(tics_per($:-1:1)),fq)')
      if hor < 20 then
         ga.y_ticks=tlist(['ticks'  'locations'  'labels'],[0:hor-1]',string(0:hor-1)')
      end
   end
 
   select fq(1)
   case 1 then
      if fq(2) == 1 then
         periods_text="years after shock"
      else
         periods_text="periods after shock"
      end
   case 2 then
      periods_text="semesters after shock"
   case 4 then
      periods_text="quarters after shock"
   case 12 then
      periods_text="months after shock"
   case 52 then
      periods_text="weaks after shock"
   case 365 then
      periods_text="days after shock"
   end
else
   periods_text="periods after shock"
end
 
 
gz=ga.z_label
gz.text="response"
gz.font_size=4
 
ghor.font_size=4
ghor.text=periods_text
 
gper.text='first estimation date'
gper.font_size=4
 
xtitle("response of "+namey(j)+' to '+namey(i))
gtit=ga.title
gtit.font_size=4
 
endfunction
