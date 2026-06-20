function []=pltirf1(res)
 
// PURPOSE: plots the results of the impulse functions from a
// var regression with one graph window per shock
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of an IRF
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2015
// http://grocer.toolbox.free.fr/grocer.html
 
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
 
for i=1:N
// one window per shock
   scf(i)
// clean the window
   clf(i)
   drawlater()
   for j=1:N
      y=[IRF(N*[0:T]+i,j) IRF_LOW(N*[0:T]+i,j) ...
         IRF_UPP(N*[0:T]+i,j)]
      // calculate the scales
      ordy=int(log10(max(abs(y))))
      ordy=ordy+(sign(ordy)-1)/2*(ordy ~= 0)
      z=y/10^ordy
      ymax=floor(max(z))+1
      ymin=floor(min(y/10^ordy))-1
      xsetech([0 (j-1)/N 1 1/N],[0,ymin,T,ymax])
      xtitle(msg+'- response of '+namey(i)+' to an innovation in '+namey(j))
      plot2d(x,y,[1 2 2],leg=strleg,frameflag=6,axesflag=5)
   end
   drawnow()
end
 
endfunction
