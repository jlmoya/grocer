function []=pltmsirf1(res)
 
// PURPOSE: plots the results of the impulse functions from a
// var regression with one graph window per shock
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of an IRF
// ------------------------------------------------------------
// Copyright: Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
r_msvar=res('msvar res')
namey=r_msvar('namey')
nendo=size(namey,1)
T=res('# irf')
nb_states=res('nb states')
 
if res('# AR') == 1 then
   if res('sigma switch') == 1 then
      irf=res('irf')
 
      for i=1:nendo
         // one window per shock
         scf()
         for j=1:nendo
            xsetech([0 (j-1)/nendo 1 1/nendo])
            y=irf(nendo*[0:T]+i,j)
            pltseries0(y,0,'response of '+namey(i)+' to an innovation in '+namey(j),string([0:T]),-1)
         end
      end
 
   else
      for st=1:nb_states
         execstr('irf=res(''irf state #'+string(st)+''')')
         for i=1:nendo
            // one window per shock
            scf()
            xsetech([0 0 1 0.1])
            titlepage('regime '+string(st))
            for j=1:nendo
               xsetech([0 0.1+0.9*(j-1)/nendo 1 0.9/nendo])
               y=irf(nendo*[0:T]+i,j)
               pltseries0(y,0,'response of '+namey(i)+' to an innovation in '+namey(j),string([0:T]),-1)
            end
         end
      end
   end
 
 
else
   for st=1:nb_states
      execstr('irf_part=res(''irf part state # '+string(st)+''')')
      execstr('irf_full=res(''irf full state # '+string(st)+''')')
      nendo=size(namey,1)
      for i=1:nendo
         // one window per shock
         scf()
         xsetech([0 0 1 0.1])
         titlepage('regime '+string(st))
         for j=1:nendo
            xsetech([0 0.1+0.9*(j-1)/nendo 1 0.9/nendo])
            y=[irf_part(nendo*[0:T]+i,j) irf_full(nendo*[0:T]+i,j)]
            pltseries0(y,0,'response of '+namey(i)+' to an innovation in '+namey(j),string([0:T]),-1...
            ,'styleg=7','leg=partial;full')
         end
      end
   end
end
 
endfunction
