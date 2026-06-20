function []=pltirf2(res)
 
// PURPOSE: plots the results of the impulse functions from a
// var regression on a unique graph
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of an IRF
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2006
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
// load the parameters that determines the fonts
load(GROCERDIR+'/param/param_g.dat')
 
rvar=res('resvar')
N=rvar('neqs')
T=res('T')
IRF=res('IRF')
IRF_LOW=res('IRF_LOW')
IRF_UPP=res('IRF_UPP')
namey=rvar('namey')
x=[(0:T)']
msg=res('msg')
 
// determine the # of tics in order to leave the scale readable
ntics = (T <= 20) ...
     + 2 * ((T > 20) & (T <= 40)) ...
     + 4 * ((T > 40) & (T <= 80)) ...
     + 4 * (floor(T/80)+1) * (T > 80)
ninter=floor(T/ntics)
xscale1=emptystr(2,1)
xscale2=string(ntics*[0:ninter])
strleg='response@'+string(100*(1-res('size')))+'% confidence band'
 
f=scf()
xsetech([0,0,1,0.1])
a=gca()
tit = a.title  // get the handle of the title
tit.text = msg // set the title
tit.font_size = max(1,5-floor(length(msg)/thresh)); // change the font size
 
for i=1:N
   for j=1:N
      y=[IRF(N*[0:T]+i,j) IRF_LOW(N*[0:T]+i,j) ...
         IRF_UPP(N*[0:T]+i,j)]
      // calculate the scales
      ordy=int(log10(max(abs(y))))
      ordy=ordy+(sign(ordy)-1)/2*(ordy ~= 0)
      z=y/10^ordy
      ymax=floor(max(z))+1
      ymin=floor(min(y/10^ordy))-1
      xsetech([(i-1)/N 0.1+0.85*(j-1)/N  1/N 0.82/N],[0,ymin,T,ymax])
      plot2d(x+1,y,[1 2 2],leg=strleg,frameflag=6,axesflag=0)
      xtitle(namey(j)+' shock to '+namey(i))
      drawy(y,1,[],1,'l')
      drawx(string(x),1,10,1,0,0,0)
   end
end
drawnow()
endfunction
