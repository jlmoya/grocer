function plt_msvarirf_cb(res)
 
// PURPOSE: plots the impulse response function from a ms_var,
// with their confidence bands
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of function dfbeta
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are plotted
// ------------------------------------------------------------
// Copyright Stefan Fiesel 2015
// pltirf_cb is part of Grocer, available at:
// http://grocer.toolbox.free.fr/grocer.html
 
 
res_msvar=res('msvar cb res')
K=res_msvar('nendo')
M=res_msvar('nb_states')
namey=res_msvar('namey')
 
IRF_part=res('irf part state')
IRF_full=res('irf full state')
INF_part=res('irf part lower cb')
INF_full=res('irf full lower cb')
SUP_part=res('irf part upper cb')
SUP_full=res('irf full upper cb')
hor=size(IRF_part,1)-1
 
for u=1:M
   for i=1:K
   // one window per shock
      scf()
      xsetech([0 0 1 0.1])
      titlepage('regime '+string(u)+' partial')
      for j=1:K
         xsetech([0 0.1+0.9*(j-1)/K 1 0.9/K])
         y=[IRF_part(:,j,i,u) , INF_part(:,j,i,u) , SUP_part(:,j,i,u)];
         pltseries0(y,0,'response of '+namey(i)+' to an innovation in '+namey(j),string([0:hor]),-1,'styleg=7')
      end
   end
end
 
for u=1:M
   for i=1:K
   // one window per shock
      scf()
      xsetech([0 0 1 0.1])
      titlepage('regime '+string(u)+' full')
      for j=1:K
         xsetech([0 0.1+0.9*(j-1)/K 1 0.9/K])
         y=[IRF_full(:,j,i,u) , INF_full(:,j,i,u) , SUP_full(:,j,i,u)];
         pltseries0(y,0,'response of '+namey(i)+' to an innovation in '+namey(j),string([0:hor]),-1,'styleg=7')
      end
   end
end
 
endfunction
