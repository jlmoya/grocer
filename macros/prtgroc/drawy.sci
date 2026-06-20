function [y0,scale]=drawy(y,font_axis,y0,x0,dircar,just_scale,rever,sep,grid,ymin,ymax)
 
// PURPOSE: draw a y axis for a graph which is readable
// whatever number of values it contains
// ------------------------------------------------------------
// INPUT:
// * y = the y matrix of the graph
// * font_axis = size of characters on the axis
// * y0 = value of the y axis where to draw the x axis or [] if
//   the user wants to put the x axis at the minimum y value
// * x0 = value of the x axis where to draw the y axis
//   (default: 1)
// * dircar= the tics direction (default: 'l', see drawaxis
//   for details)
// * just_scale = %t to have the scale excatly covering the
//   min and max of the data, %f if the scale is rounded
// * rever = %t to have the scale inverted
// * sep = the separator used for decimal values
// * grid = %t to have grids drawn hoizontally
// * nobs = # of obsvervations on the x axis (used to draw the
//   grid)
// ------------------------------------------------------------
// OUPTUT:
// * y0 = value of the y axis where to draw the x axis
// * scale = the col vector of values reported on the scale
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2011
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
ynonna=y(~isnan(y))
// determine the range of the y axis
if nargin < 11 then
   ymax=[]
end
if nargin < 10 then
   ymin=[]
end
if nargin < 9 then
   grid=%t
end
if nargin < 8 then
   sep='.'
end
if nargin < 7 then
   rever=0
end
if nargin < 6 then
   just_scale=%f
end
if nargin < 5 then
   dircar='l'
end
if nargin < 4  then
   x0=1
end
 
[nobs,ny]=size(y)
if ~isempty(ymin) then
    y0=ymin
end
 
yused=[y0 ; ynonna]
if ~isempty(ymax) then
   yused=[yused ; ymax]
end
[scale,ymin,ymax]=yscale([y0 ; ynonna ; ymax],just_scale)
 
scaleb=string(scale)
if sep ~= '.' then
   scaleb=strsubst(string(scale),'.',',')
   l=max(length(scaleb))
   for i=1:size(scaleb,2)
      scalei=scaleb(i)
      indsep=strindex(scaleb(i),sep)
      if isempty(indsep) then
         z=emptystr(l-2)+'0'
         scaleb(i)=scalei+sep+z
      end
   end
end
 
// scale is the vector of values that will be drawn
lasttic=size(scale,2)
if y0 == [] then
   y0=min(scale)
   y00=[]
else
   y00=y0
end
 
 
if grid & getversion("scilab")(1) > 4 then
   // add a grid to the graph
   // does not work properly with Scilab 4.1.2 and lower
   grey=addcolor([0.65 0.65 0.65])
   ind=find(scale == y00)
   grids=1:size(scale,'*')
   grids(ind)=[]
   for i = grids
      plot2d([1:nobs],ones(1,nobs)*scale(i),1,axesflag=0)
      g=gca()
      gc=g.children(1)
      polyl=gc.children
      polyl.thickness=1
      polyl.line_style=2
      polyl.foreground=grey
   end
end
 
if just_scale then
   drawaxis(y=[scaleb(lasttic) max(ynonna)],x=x0,dir=dircar,tics='v',fontsize=font_axis,val=emptystr(2,1),sub_int=0)
   drawaxis(y=[min(ynonna) scaleb(1)],x=x0,dir=dircar,tics='v',fontsize=font_axis,val=emptystr(2,1),sub_int=0)
   drawaxis(y=scaleb,x=x0,dir=dircar,tics='v',fontsize=font_axis,sub_int=0)
   scaleb=[ymin,ymax]
else
   drawaxis(y=scale,x=x0,dir=dircar,tics='v',fontsize=font_axis,sub_int=0,val=scaleb)
end
 
if rever then
   ga=gca()
   ga_ch=ga.children
   ga_ch_axis=ga_ch($)
   ga_ch_axis.tics_labels=string(-ga_ch_axis.ytics_coord)
end
 
 
endfunction
