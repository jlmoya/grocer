function histg(grocer_namey,grocer_n,grocer_color,grocer_wind)
 
// PURPOSE: plots as an histogram the probability distribution
// function of a variable
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
//   string equal to the name of a time series or a (nx1) real
//   vector between quotes
// * grocer_n= # of bars of the histogramm
// * grocer_color= numerical representation of the color used
//   for the bars
// * grocer_wind = the window number (optional: by default a
//   new window is open)
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the graphic window
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
[nargout,nargin]=argn(0)
if nargin  ~= 4 then
   grocer_wind=scf()
   grocer_wind=grocer_wind.figure_id
else
   scf(grocer_wind)
end
 
// load the parameters that determines the fonts
load(GROCERDIR+'/param/param_g.dat')
 
if typeof(grocer_namey) == 'string' then
   tit='pdf for variable '+grocer_namey
else
   tit='pdf'
end
 
[y,namey,prests,b]=explone(grocer_namey,[],'unknown')
z=linspace(min(y),max(y),grocer_n+1)
[ind,occ]=dsearch(y,z)
 
drawlater()
 
xtitle(tit)
f_title=max(1,5-floor(length(tit)/thresh))
a = gca() ; // get the current axis
tit = a.title ; // get the handle of the title
tit.font_size = f_title ; // change the font_size
 
if size(grocer_color,'*') == 3 then
   grocer_color=addcolor(grocer_color)
end
 
for i=1:grocer_n
    xrects([z(i),occ(i),z(i+1)-z(i),occ(i)]',grocer_color)
end
 
X = [z(1);z(1);matrix([1;1;1]*z(2:grocer_n),-1,1);z(grocer_n+1);z(grocer_n+1)]
Y = [matrix([0;1;1]*occ,-1,1);0]
plot2d(X,Y)
ax=gca()
ax.font_size=4
 
 
drawnow()
 
endfunction
