function []=fan_chart(mat,dat,win,colour,sep,leg,sizes)
 
// PURPOSE: draws a fan-chart as the ones used by the Bank of
// England
// ------------------------------------------------------------
// INPUT:
// * mat=a (T x (2*k+1)) probability matrix with the median
//   recorded in column k+1
// * dat=a (T x 1) vector of dates
// * win=the window's number
// * colour='blue' or 'grey'
// * sep=the decimal separator used for the figures
// * leg = a boolean indicating whether a legend is added to
//   the chart
// * sizes = the confidence interval sizes displayed in the
//   legend (if any)
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are printed on the graphic window
// ------------------------------------------------------------
// Copyright: Eric Dubois 2008-2022
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
[nargout,nargin]=argn(0)
if nargin <= 5 then
   leg=%f
end
if nargin <= 4 then
   sep='.'
end
 
band_width=mat($,:)-mat(1,:)
ind_fore=find(band_width~=0)
ind_lastdata=max(1,ind_fore(1)-1)
// load the parameters that determines the fonts
load(GROCERDIR+'/param/param_g.dat')
just_scale=%f
 
if ~isempty(win) then
   // clear the current window if needed
   scf(win)
   clf(win)
end
f=gcf()
cmap0=f.color_map
ncolors0=size(cmap0,1)
 
drawlater()
nbands=size(mat,1)
nx=size(mat,2)
a=gca()
a.data_bounds=[1,min(mat);nx,max(mat)]
half=floor(nbands/2)+1
 
select colour
 
case 'blue' then
   if half >=5 then
      cmap=[cmap0; 0 0 0 ; [0.2 0.3 0.4 linspace(0.5,0.8,half-4)]' .*. ones(1,2) 0.9*ones(half-1,1)]
   else
      cmap=[cmap0; 0 0 0 ; [linspace(0.2,0.8,half-1)]' .*. ones(1,2) 0.9*ones(half-1,1)]
   end
   f.color_map=cmap
   colors=ncolors0+1:ncolors0+half
 
case 'grey'
   f.color_map=[cmap0 graycolormap(4*nbands)]
   colors=[ncolors0+1 ncolors0+3*nbands-floor(5*[half:-1:1]-16)]
 
else
    if or(colour == ['autumn' ; 'bone' ; 'cool' ; 'copper' ; 'hot' ;'ocean' ;'pink' ;'spring' ; 'summer';'winter'])  then
       cmap=[cmap0 ; evstr(colour+'colormap('+string(4*nbands))]
       colors()
    else
       error(colour+' is not available for a fan chart')
       colors=[ncolors0+1 ncolors0+4*nbands-floor(5*[half:-1:1]-16)]
    end
end
 
 // create the y axis and recover y0 and the scale
[y0,scale]=drawy(mat',font_axis,[],1,'l',just_scale,0,sep,%t)
nscale=size(scale,2)
// draw the x axis at the defined y0 value and recover the values
// of the x axis which are displayed
x_tics=drawx(dat,1,ref_nbinter,font_axis,y0)
// calculate the space between displayed tics
space=(x_tics(2)-x_tics(1))/x_tics(3)

// if the user wants a legend, then start with it, so that the
// curve is not covered by the legend
if leg then
   // select if it should be below or above the known data
   length_axex=size(mat,2)
   rect=xstringl(1+0.1*length_axex,0,'50% confidence interval')
   ind_mat=ceil(rect(1)+rect(3))
   scalemin=scale(1)
   scalemax=scale($)
   dist=[min(mat(1,1:ind_mat)-scalemin)  scalemax-max(mat(1,1:ind_mat))]
 
   [junk,ind_maxdist]=max(dist)
   if ind_maxdist == 1 then
      upper=0.7*scalemin+0.3*scalemax
   else
      upper=0.95*scalemax+0.05*scalemin
   end
   width=(scalemax-scalemin)*0.45
   xpoly(1+[0.02 0.08]*length_axex,(upper-0.1*width)*[1 1])
   e=gce()
   e.line_style=1
   e.thickness=5
 
   xstring(1+0.1*length_axex,(upper-0.14*width)*[1 1],' ')
   f=gce()
   f.font_size=4
   f.text='Median forecast'
 
   for i=1:half-1
      xfpoly([1+[0.02 0.08]*length_axex 1+0.08*length_axex 1+0.02*length_axex],...
             [(upper-(0.14+0.12*i)*width)*[1 1] (upper-(0.10+0.12*(i+1))*width)*[1 1]],colors(half-i+1))
      xstring(1+0.1*length_axex,upper-(0.22+0.12*i)*width,' ')
      f=gce()
      f.font_size=4
      f.text=string(100*sizes(half-i))+'% confidence interval'
   end
 
end
 
for i=1:half-2
   xfpoly([ind_lastdata:nx nx:-1:ind_lastdata],[mat(i,ind_lastdata:nx) mat(i+1,nx:-1:ind_lastdata)],colors(half-i+1))
   xfpoly([ind_lastdata:nx nx:-1:ind_lastdata],[mat(nbands-i+1,ind_lastdata:nx) mat(nbands-i,nx:-1:ind_lastdata)],colors(half-i+1))
end
 
rectc=[1 scale(1) nx scale($)]
// band at the center
xfpoly([ind_lastdata:nx nx:-1:ind_lastdata],[mat(half-1,ind_lastdata:nx) mat(half+1,nx:-1:ind_lastdata)],colors(2))

// draw the median 
plot2d([1:nx],mat(half,:),axesflag=0,rect=rectc)
g=gca()
gc=g.children(1)
polyl=gc.children
// determine the thickness of the median so that it does not mask the bands
polyl.thickness=min(5,max(1,10*mean(band_width)/(scale($)-scale(1))) )
polyl.line_style=1
 
plot2d([1:nx],scale(nscale)*ones(1,nx),axesflag=0)
g=gca()
gc=g.children(1)
polyl=gc.children
polyl.line_style=1
 
grey=addcolor([0.65 0.65 0.65])

// add grids to the graph, defined on the represented tics of the x axis
xsegs([space+1:space:x_tics(2) ; space+1:space:x_tics(2)],[scale(1)*ones(1,x_tics(3)) ;scale($)*ones(1,x_tics(3))],grey)
g=gca()
gc=g.children(1)
gc.thickness=1
gc.line_style=2
 
 
drawnow()
 
endfunction
