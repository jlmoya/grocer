function pltbrybos(res,win)
 
// PURPOSE: plots the results of the Bry-Boschan function
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list from function brybos
// * win = the numbered window where to plot (default: the
//   first not open)
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are plotted
// ------------------------------------------------------------
// Copyright E. Michaux/E. Dubois 2005-2006
// http://grocer.toolbox.free.fr/grocer.html
 
 
global GROCEDIR;
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   hf=scf()
else
   hf=clf(win)
   scf(win)
end
// add a grey color to the current colormap: used to draw the
// recession shaded area
grey=addcolor([0.8 0.8 0.8])
 
// load the parameters that determines the fonts
load(GROCERDIR+'/param/param_g.dat')
 
drawlater()
y = res('y')
nobs = size(y,1)
 
nbcpf=res('ind_peaks')
nbctf=res('ind_troughs')
// set the values of the x axis:
bo=res('bounds')
for i=1:size(bo,1)/2
   d1=date2num(bo(i*2-1))
   xscale0=num2date([d1:d1+diff_date(bo(2*i),...
           bo(2*i-1))],date2fq(bo(i*2-1)))
end
 
x = (1:nobs)'
 
if nbctf(1) < nbcpf(1) then
// the first turning point is a trough; then ignore it
   nbctf=nbctf(2:$)
end
 
if nbcpf($) > nbctf($) then
// the last turning point is a peak; add the last observation as a "trough"
   nbctf=[nbctf; nobs]
end
npeaks=size(nbctf,1)
 
if res('filter') == 'none' then
   ymin = min(y)
   ymax = max(y)
   dy = (ymax - ymin)*0.05;
   [y0,scale]=drawy(y,font_axis,[])
   yminn=min(ymin,scale(1))
   ymaxn=max(ymax,scale($))
   rectc=[1,min(ymin,scale(1)) - dy,size(y,1),max(ymax,scale($))+dy]
   // draw the shaded areas
   for i=1:npeaks
      xrects([nbcpf(i),ymaxn,nbctf(i)-nbcpf(i),ymaxn-yminn]',grey)
    end
 
   // draw the series
   plot2d(x,y,style=1,frameflag=5,rect=rectc,axesflag=0)
   drawx(xscale0,1,ref_nbinter,font_axis,y0)
   // materialize peaks and troughs
   plot2d(nbcpf,y(nbcpf),style=-6,frameflag=0,axesflag=0)
   plot2d(nbctf,y(nbctf),style=-7,frameflag=0,axesflag=0)
   titl='Turning points analysis of '+res('namey')
   a=gca() // get the current axis
   tit = a.title  // get the handle of the title
   tit.text = titl  // set the title
   tit.font_size = max(1,5-floor(length(titl)/thresh)) ; // change the font size
   legends(['Observed';'Peaks';'Troughs'],[1,-6,-7],2)
 
else
   fy = res('filt. y')
   yn=[y fy]
   ymin = min(yn)
   ymax = max(yn)
   dy = (ymax - ymin)*0.05;
   [y0,scale]=drawy(yn,font_axis,[])
   yminn=min(ymin,scale(1))
   ymaxn=max(ymax,scale($))
   rectc=[1,min(ymin,scale(1)) - dy,size(y,1),max(ymax,scale($))+dy]
   // draw the shaded areas
   for i=1:npeaks
      xrects([nbcpf(i),ymaxn,nbctf(i)-nbcpf(i),ymaxn-yminn]',grey)
    end
 
   drawx(xscale0,1,ref_nbinter,font_axis,y0)
   // draw the series
   plot2d(x,[y fy],style=[1,2],frameflag=5,rect=rectc,axesflag=0)
   // materialize peaks and troughs
   plot2d(nbcpf,y(nbcpf),style=-6,frameflag=0,axesflag=0)
   plot2d(nbctf,y(nbctf),style=-7,frameflag=0,axesflag=0)
   titl='Turning points analysis of '+res('namey') +' transformed by a '+res('filter')
   a=gca() // get the current axis
   tit = a.title  // get the handle of the title
   tit.text = titl  // set the title
   tit.font_size = max(1,5-floor(length(titl)/thresh)) ; // change the font size
   legends(['Observed';res('filter');'Peaks';'Troughs'],[1,2,-6,-7],2)
end
 
drawnow()
 
endfunction
 
