function  plt_rol_vargranger(res,option)
 
// PURPOSE: plots the results of Ganger (non-)causality tests
// for a rolling VAR
// ------------------------------------------------------------
// INPUT:
// * res = a 'rolling var Granger causality' results tlist
// * option = the result the user wants to ^plot ('chi2 stat',
//    'chi2 pvalue', 'Fisher stat' or 'Fisher pvalue')
// ------------------------------------------------------------
// OUTPUT:
// NOTHING : results are plotted on a graphic window
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
 
y=res(option)
causing=res('causing')
caused=res('caused')
 
resvar=res('rolvar res')
namey=resvar('namey')
 
if resvar('prests') then
   firstb=resvar('start firstbound')
   [daten,fq]=date2num_fq(firstb)
   xscale=num2date(daten+[0:size(y,1)-1],fq)
   titl=option+' for rolling Granger non-causality from '+strcat(namey(causing),' - ')+...
       ' to '+strcat(namey(caused),' - ')
   pltseries0(y,0,titl,xscale,[],'noleg')
   xlabel('start of estimation period')
   a=get('current_axes')
   x_lab=a.x_label
   x_lab.font_size=4
   pos=x_lab.position
   [scale,ymin,ymax]=yscale(y,%f)
   pos(2)=-0.1*ymax
   x_lab.auto_position = "off"
   x_lab.position=pos
 
end
 
endfunction
