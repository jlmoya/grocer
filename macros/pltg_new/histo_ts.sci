function histo_ts(grocer_namey,grocer_color,grocer_tit,dilat,grocer_wind)
 
// PURPOSE: plots series with bars as in Excel
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
//   string equal to the name of a time series or a (nx1) real
//   vector between quotes
// * grocer_color=
//   either:
//   * a scalar, the numerical representation of the color used
//   for the bars
//   * a (1 x n) vector, the numerical representation of the
//   color used for the bars (one per bar)
//   * a (k x n) vector, the numerical representation of the
//   color used for the bars, one per bar, each column
//   representing the RGB color definition.
// * grocer_dilat = the dilatation factor applied to the
//   default axis font
// * grocer_wind= the window number (optional: by default a
//   new window is open)
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the graphic window
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
[nargout,nargin]=argn(0)
if nargin  ~= 5 then
   scf()
end
 
// load the parameters that determines the fonts
load(GROCERDIR+'/param/param_g.dat')
font_axis=floor(dilat*font_axis)
 
if ~exists('grocer_tit') & typeof(grocer_namey) == 'string' then
   grocer_tit=grocer_namey
end
 
bounds()
[y,namey,prests,b]=explone(grocer_namey,[],'unknown',%f,%f)
//z=linspace(min(y),max(y),grocer_n+1)
//[ind,occ]=dsearch(y,z)
ny=size(y,1)
if size(grocer_color,1) == 1 then
   grocer_color=grocer_color .*. ones(ny,1)
end
unit=6
leng=unit+2
x=zeros(1,leng*size(y,1))
x(ones(1,ny) +leng*[0:ny-1])=1+unit*[0:ny-1]
x(ones(1,ny) .*. [2:3] +leng*[0:ny-1] .*. ones(1,2))=[2+unit*[0:ny-1]] .*. ones(1,2)
x(ones(1,ny) .*. [4:unit] +leng*[0:ny-1] .*. ones(1,unit-3))=ones(1,ny) .*. [3:unit-1]+ (unit*[0:ny-1]) .*. ones(1,unit-3)
x(ones(1,ny) .*. [unit+1:unit+2] +leng*[0:ny-1] .*. ones(1,2))=unit*[1:ny] .*. ones(1,2)
indbars=ones(1,ny) .*. [3:unit+1] + leng*[0:ny-1] .*. ones(1,unit-1)
z=zeros(1,ny*leng)
 
z(indbars)=y' .*. ones(1,unit-1)
 
drawlater()
 
xtitle(grocer_tit)
f_title=max(1,5-floor(length(grocer_tit)/dilat/thresh))
a = gca() ; // get the current axis
tit = a.title ; // get the handle of the title
tit.font_size = f_title ; // change the font_size
 
grocer_color0=grocer_color(1,:)
if size(grocer_color0,2) == 3 then
   colorc=addcolor(grocer_color(1,:))
elseif size(grocer_color,'*') == 1 then
   colorc=grocer_color0*ones(1,ny)
else
   colorc=grocer_color0
end
 
for i=1:ny
   if grocer_color(i,:) ~= grocer_color0 then
      grocer_color0=grocer_color(i,:)
      if size(grocer_color0,2) == 3 then
         colorc=addcolor(grocer_color(i,:))
      else
         colorc=grocer_color(i)
      end
   end
   xrects([x(3+leng*(i-1)),max(y(i),0),unit-2,abs(y(i))]',colorc)
end
 
plot2d(x,z,1,axesflag=0)
[datenum1,fq]=date2num_fq(b(1))
datenum2=date2num_fq(b($))
//xscale=emptystr(1,ny*2+1)
////xscale(int((unit+1)/2)+[0:ny-1]*unit)=num2date([datenum1:datenum2],fq)
xscale=num2date([datenum1:datenum2],fq)
nobs=size(xscale,2)
ncars=max(length(xscale))
ninter=floor(ref_nbinter/ncars)
ntics=max(floor(nobs/ninter)+1,1)
ninter=floor(nobs/ntics)
flagint=bool2s(ninter*ntics == nobs)
lasttics=ntics*(ninter-flagint)+1
 
xaux=xscale(1+ntics*[0:ninter-flagint])
 
if and(y>0) | and(y<0) then
   [y0,scale]=drawy(y .*. ones(unit,1),font_axis,0,1,'l',%f,0,'.',%t,0)
else
   [y0,scale]=drawy(y .*. ones(unit,1),font_axis,0,1,'l',%f,0,'.',%t)
end
 
drawaxis(x=leng/2+unit*ntics*[0:ninter-flagint],y=0,dir='d',tics='v',fontsize=font_axis,val=xaux)
ax=gca()
ax1=ax.children(1)
ax1.labels_font_color = 1
// remove ugly tics
ax1.sub_tics=0
 
drawaxis(x=[1 leng/2],y=0,dir='d',tics='v',fontsize=font_axis,val=emptystr(2,1)+' ')
ax=gca()
ax1=ax.children(1)
ax1.labels_font_color = -1
ax1.sub_tics=0
drawaxis(x=[leng/2+unit*ntics*(ninter-flagint) ny*unit],y=0,dir='d',tics='v',fontsize=font_axis,val=emptystr(2,1)+' ')
aax=gca()
ax1=ax.children(1)
ax1.labels_font_color = -1
ax1.sub_tics=0
 
 
drawnow()
 
endfunction
