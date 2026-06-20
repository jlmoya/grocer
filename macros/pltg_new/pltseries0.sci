function []=pltseries0(y,y0,titl,xscale0,wind,varargin)

// PURPOSE: plots series... (scilab function plot2d, but with
// some scilab parameters fixed and new possibilities, such as
// ts, the mixing of bars and curves, the possibility to have
// 2 different axes,...)
// ------------------------------------------------------------
// INPUT:
// * y = the (n x p) values real matrix of the graphed series
// * y0 = the value where to draw the x axis or [] if the user
//   wants the axis to be put a the y minimum value
// * titl = title of the graph
// * xscale0 = a (n x 1) string vector representing the x scale
// * wind = the number of the window where to draw the graph
//   (-1 if the user wants to draw it on the currently opened
//    window)
// * varargin = optional arguments:
//   - 'styleg =xx' with xx integer row vector of size p
//     representing the location of the legend
//     (default: 5, that is the legend is placed interactively
//      with the mouse, see legends in the help menu)
//   - 'style = xx' with xx integer row vector of size p
//     representing the line style of each series
//   - 'thickn = xx' with xx integer row vector of size p
//     representing the thickness of the line drawn for each
//     series (default all equal to 1)
//   - 'color = xx' with xx integer row vector of size p
//      representing the line color of each series
//   - 'mycolor=[r1,g1,b1;...;rp,gp,bp]' for user defined colors
//            with ri,gi,bi the RGB integer values of a color
//   - 'leg = tit' with tit = title of the legend
//   - 'yaxis = xx' with xx integer row vector of size p
//     representing the axis for each series (1=left; 2=right)
//   - 'bars = xx' with xx integer row vector of size p
//     representing the nature of the representation of the
//     series (1=bars; anything else = curves)
//   - 'x0(1)=xx' with xx integer representing the x location
//     of the first y axis (default: put at x=1)
//   - 'x0(2)=xx' with xx integer representing the x location
//     of the second y axis (default: put at x=nobs)
//   - 'shade=xx' a (nx1) vector composed of 0 and 1 where
//          1 delimits areas to be shaded
//   - 'wsize = [horizontal scaling, vertical scaling]'
//        to change the size of the graph window
//   - 'xlabel=xx' with xx the label of x-axis
//   - 'ylabel=xx' with xx the label of y-axis
//   - 'font_legend=xx' with xx the size of the legend font
//   - 'font_axis=xx' with xx the size of the axis font
//   - 'font_title=xx' with xx the size of the title font
//   - 'font_xlabel=xx' with xx the size of the x-axis label
//   - 'font_ylabel=xx' with xx the size of the y-axis label
//        if the graph has 2 axes xx  could be (2x1) or a scalar
//   - 'style_title=xx' with xx the font style of the title
//   - 'ntics=xx' # of tics between 2 occurences of the axis values
//   - 'just_scale=bool' with bool a boolean which is:
//     * %T if you want the y scale to be exactly the length
//      [min(y),max(y)]
//     * %f if you want the y scale to begin and end with
//      rounded numbers (default)
//   - 'reverse = xx' with xx integer row vector of size 2
//     of 0 and 1: 0 if series are drawn in increasing order
//                 1 if series are drawn in decreasing
//     (default: all series plotted in increasing order)
//   - 'minyi=xxx' if the user wants to impose the min value on
//     the i-th (i=1 for left; i=2 for right) y axis to xxx
//   - 'maxyi=xxx' if the user wants to impose the max value on
//     the i-th (i=1 for left; i=2 for right) y axis to xxx
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are printed on the graphic window
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2015
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
// load the parameters that determines the fonts
load(GROCERDIR+'/param/param_g.dat')
 
nargin=length(varargin)
[nobs,ny]=size(y)
// set default values
secondaxis=%f
style=[1:ny]
styleg=6
bars=zeros(ny,1)
x0=[1 nobs]
x0given=%f
ydeb=[]
just_scale=%f
thickn=ones(ny,1)
xscale0=vec2row(xscale0)
yscale0=[]
xlab=[]
ylab=[]
font_legend=4
font_axis=3
font_xlabel=2
font_ylabel=2
style_title=6
reverse=zeros(ny,1)
ntics=[]
ninter=[]
wsize=[]
y_1=[1:ny]
y_2=[]
sep='.'
shade=[]
grid=%T
miny1=[]
maxy1=[]
miny2=[]
maxy2=[]
leg=%f
 
for i=1:nargin
   argi=varargin(i)
   indeq=strindex(argi,'=')
   if isempty(indeq) then
      if argi == 'nogrid' then
         grid=%f
      end
 
   else
      begc=strsubst(part(argi,1:indeq-1),' ','')
      endc=part(argi,indeq+1:length(argi))
      if or(begc == ['styleg';'thickn';'style';'bars';'x0';...
          'font_legend';'font_axis';'font_xlabel';'font_ylabel';...
         'style_title';'ntics';'reverse';'just_scale';'sep';...
         'miny1';'maxy1';'miny2';'maxy2']) then
         execstr(argi)
      elseif begc == 'color' then
         pltcol=vec2row(evstr(endc))
      elseif begc == 'font_title' then
         f_title=evstr(endc)
      elseif begc == 'xlabel' then
         xlab=endc
      elseif begc == 'ylabel' then
         ylab='ylabel='+endc
         ylab=strsubst(ylab,',',';')
         ylab=str2vec(ylab)
      elseif begc == 'leg' then
         legend0=str2vec(varargin(i))
         leg=%t
      elseif begc == 'mycolor' then
         pltcolu=evstr(endc)
      elseif begc == 'wsize' then
         wsize=evstr(endc)
      elseif begc == 'shade' then
         shade=evstr(endc)
      elseif part(begc,1:6) == 'yscale' then
         yscale0=evstr(endc)
      elseif begc == 'yaxis' then
         execstr(argi)
         if or(yaxis~=1) then
            y_1=find(yaxis == 1)
            y_2=find(yaxis ~= 1)
            secondaxis=%t
         end
      end
   end
end
 
min_x0=int(min(x0))
max_x0=int(max(x0))
// This test is necessary for the case when the function
//  is called by mpltseries. Because of the use of subplot
//  function mpltseries creates its own graphic window
if isempty(wind) then
   scf()
else
   if wind ~= -1 then
      scf(wind)
      // clean the screen:
      clf(wind)
   end
end
 
// rescale the size of the graph window
if wsize~=[] then
  if size(wsize,'*')==1
    wsize=[wsize(1),1]
  end
  f=get("current_figure");
  f.figure_position=[0.5,0.5];
  f.figure_size=wsize(:)'.*f.figure_size;
end
 
// user defined color
if exists('pltcolu','local')
  if size(pltcolu,'*')<ny then
    error('# of user defined colors doesn''t macth with the # of series')
  end
  pltcol=[]
  for c=1:size(pltcolu,1)
    execstr('pltcol=[pltcol,color(pltcolu('+string(c)+',1),pltcolu('+string(c)+',2),pltcolu('+string(c)+',3))]')
  end
end
 
drawlater()
 
ny2=size(y_2,2)
nbars=sum(bars(y_1)==1)
if nbars ~= 0 then
// if there are bars in the graph, then the x axis is drawn at y=0
   y0=0
   if ~x0given then
      min_x0=0
   end
end
 
yext1=[]
yext2=[]
if min_x0 <=0 then
   yext1=%nan*ones(-min_x0+1,1)
end
 
if max_x0 > nobs then
   yext2=%nan*ones(max_x0-nobs+1,1)
end
 
// interval between 2 occurences of the axis values
// compatible with ntics
if length(ntics)>0 then
  ninter=floor(max_x0/ntics)
end
 
ga=gca()
ga.font_size =font_axis
ga.line_style = 1
 
// choose default colors
if ~exists('pltcol','local') then
   pltcol=[1 2 5 14 24 3:4 6:13]
   pltcol=pltcol(1:ny)
end
 
// in a graph with several bars (and maybe curves)
// width_bars is the length occupied by the bars (+ a blank)
// and xdeb is the n� of the bar where the curves are located
// xending is the length remaining after the end of the curve
 
width_bars=nbars+bool2s(nbars>1)
xdeb=max(floor((width_bars+bool2s(nbars>1))/2),1)
xending=width_bars-xdeb
 
// draw y axis
if isempty(yscale0) then
   [y0,scale]=drawy(y(:,y_1)*(1-2*reverse(1)),font_axis,y0,1,'l',just_scale,reverse(1),sep,grid,miny1,maxy1)
else
   select typeof(yscale0)
   case 'list' then
      scale=yscale0(1)
      if length(yscale0) == 2 then
         scale2=yscale0(2)

      end
   case 'constant' then
      scale=yscale0
   end
   drawaxis(y=scale,x=1,dir='l',tics='v',fontsize=font_axis,sub_int=0,val=string(scale))
   if y0 == [] then
      y0=scale(1)
   end
   if grid & getversion("scilab")(1) > 4 then
      // add a grid to the graph
      // does not work properly with Scilab 4.1.2 and lower
      grey=addcolor([0.65 0.65 0.65])
      ind=find(scale == y0)
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

end

maxy1=max(scale)
miny1=min(scale)
if length(shade)>0
// shade area between two points
  sh=find(shade~=0)
  i1=find(diff(sh)~=1)+1
  i1=[1,i1,length(sh)];
  yminn=min(miny1,scale(1))
  ymaxn=max(maxy1,scale($))
  grey=color(208,208,204)
  for s=1:(size(i1,'*')-1)
    xrects([sh(i1(s)),ymaxn,(i1(s+1)-1)-i1(s)+1,ymaxn-yminn]',grey)
  end
end
 
 
if secondaxis then
   y2=y(:,y_2)*(1-reverse(2)*2)
   if ~exists('scale2') then
      [scale2,miny2c,maxy2c]=yscale(y2,just_scale)
      if isempty(maxy2) then
         maxy2=max(maxy2c,scale2($))
      end
      if isempty(miny2) then
         if or(bars(y_2) == 1) then
            miny2=min(miny2c,scale2(1),0)
         else
            miny2=min(miny2c,scale2(1))
         end
      end
   else
      miny2=scale2(1)
      maxy2=scale2($)
   end
 
// determine the scaling factor applying to series on axis # 2:
// the size of the graph is determined by the first axis and
// series on the second axis are adjusted to this size, with the
// second axis keeping trace of the true intial values in scale2
 
   den=(maxy2-miny2)
   cte=(miny1*maxy2-maxy1*miny2)/den
   deriv=(maxy1-miny1)/den
 
   y2=y2*deriv+cte
   scale=scale2*deriv+cte
   scale2=scale2*(1-reverse(2))-reverse(2)*scale2
 
   if just_scale then
      drawaxis(y=scale,x=max_x0,dir='r',tics='v',fontsize=font_axis,sub_int=0,val=string(scale2),textcolor=1,ticscolor=1)
      drawaxis(y=[miny1 scale(1)],x=max_x0,dir='r',tics='v',fontsize=font_axis,sub_int=0,val=emptystr(2,1),textcolor=1,ticscolor=1)
      drawaxis(y=[scale(size(scale,2)) maxy1],x=max_x0,dir='r',tics='v',fontsize=font_axis,sub_int=0,val=emptystr(2,1),textcolor=1,ticscolor=1)
   else
      drawaxis(y=scale,x=max_x0,dir='r',tics='v',fontsize=font_axis,sub_int=0,val=string(scale2),textcolor=1,ticscolor=1)
  end
end
 
if (length(ninter)==0) | (length(ntics)==0) then
  drawx(xscale0,max(width_bars,1),ref_nbinter,font_axis,y0,max(0,-min_x0+1),max(0,max_x0-nobs))
else
  //# of tics between 2 occurences of the axis values
  drawx(xscale0,max(width_bars,1),ref_nbinter,font_axis,y0,max(0,-min_x0+1),max(0,max_x0-nobs),ninter,ntics)
end
rectc=[1,miny1,max(width_bars,1)*(size(xscale0,2)+1)+max(0,-min_x0+1)+max(0,max_x0-nobs)+1,maxy1]
 
bari=0
ny1=size(y_1,2)
for i=1:ny1
   i1=y_1(i)
   yi=y(:,i1)*(1-2*reverse(1))
   if bars(i1) == 1 then
      bari=bari+1
      ga=gca()
      ga.thickness = 1
      yext=[yext1 ; yi .*. [0*[1:bari-1]' ; 1 ; 0*[bari+1:nbars+bool2s(nbars>2)]' ] yext2]
      [listx,listy]=dealyna(yext)
      for j=1:length(listx)
         plot2d3(listx(j),listy(j),pltcol(i1),axesflag=0,rect=rectc)
         gc=ga.children(1)
         polyl=gc.children
         polyl.thickness=thickn(i1)
         polyl.line_style=style(i1)
      end
   else
      if nbars > 1 then
         yext=[yext1 %nan*ones(1,xdeb-1) interpln([xdeb+width_bars*[0:nobs-1] ; yi'],...
               [xdeb:xdeb+width_bars*(nobs-1)]) %nan*ones(1,xending) yext2]
      else
         yext=[yext1 yi' yext2]
      end
      [listx,listy]=dealyna(yext)
      for j=1:length(listx)
         plot2d(listx(j),listy(j),pltcol(i1),axesflag=0,rect=rectc)
         ga=gca()
         gc=ga.children(1)
         polyl=gc.children
         polyl.thickness=thickn(i1)
         polyl.line_style=style(i1)
      end
   end
end
 
// draw a label on x
ga=gca()
if (size(xlab,'*')>0) then
  ht=ga.x_label
  ht.text=xlab
  ht.font_size=font_xlabel
end
// draw a label on y
if (size(ylab,'*')>0) then
  ht=ga.y_label
  ht.text=ylab(1)
  ht.font_size=font_ylabel(1)
end
 
if secondaxis then
   for i=1:ny2
      i2=y_2(i)
      yi=y2(:,i)
      if bars(i2) == 1 then
         bari=bari+1
         ga=gca()
         ga.thickness = 1
         yext=[yext1 ; yi .*. [0*[1:bari-1]' ; 1 ; 0*[bari+1:nbars+bool2s(nbars>2)]' ] yext2]
         [listx,listy]=dealyna(yext)
         for j=1:length(listx)
            plot2d3(listx(j),listy(j),pltcol(i2),axesflag=0,rect=rectc)
         end
         gc=g.children(1)
         polyl=gc.children
         polyl.thickness=thickn(i1)
         polyl.line_style=style(i1)
      else
         if nbars > 1 then
            yext=[yext1 interpln([xdeb+width_bars*[0:nobs-1] ; yi'],[xdeb:xdeb+width_bars*(nobs-1)]) yext2]
         else
            yext=[yext1 yi' yext2]
         end
         ga=gca()
         ga.thickness = 1+(nbars~=0)
         [listx,listy]=dealyna(yext)
         for j=1:length(listx)
            plot2d(listx(j),listy(j),pltcol(i2),axesflag=0,rect=rectc)
         end
         g=gca()
         gc=g.children(1)
         polyl=gc.children
         polyl.thickness=thickn(i2)
         polyl.line_style=style(i2)
      end
// now change the curves style to the one given by the user
// note that the last curve is in the first place in
   end
//   gc_axis=g.children($)
//   gc_axis.tics_labels=string(scale2)
end
 
i1=2-just_scale
i2=size(scale,2)
 
 
if ~isempty(titl)  then
   if ~exists('f_title','local')
      f_title=max(1,6-floor(length(titl)/thresh))
   end
   ga=gca() // get the current axis
   tit = ga.title  // get the handle of the title
   tit.text = titl  // set the title
   tit.font_size = f_title ; // change the font size
   tit.font_style=style_title // change the font style
end
drawnow()
 
if leg then
   nleg=size(legend0,'*')
   col_legend=vec2row(pltcol(1:nleg))
   style_legend=vec2row(style(1:nleg))
   legends_groc(legend0,[evstr(col_legend) ; style_legend],styleg,with_box=%f,font_legend)
 
   h=gce()
   nleg=size(legend0,'*')
   for i=1:nleg
      hi=h.children(2*(nleg-i+1))
      hi.thickness=thickn(i)
   end
end
 
endfunction
 
