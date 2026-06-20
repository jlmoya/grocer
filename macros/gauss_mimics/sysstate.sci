function ret=sysstate(ind,y)
 
// PURPOSE: mimics gauss function sysstate
// ------------------------------------------------------------
// INPUT:
// * ind = a scalar between 1 and 34
// * y = an option
// ------------------------------------------------------------
// OUTPUT:
// * ret = the old value
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR grocer_sysstate;
load(GROCERDIR+'\param\sysstate.dat')
 
ret=list_sysstate(ind)
if ind >=2 & ind <=7 then
   grocer_sysstate(ind)=y
 
elseif ind == 13 then
   if y > 0 then
      grocer_sysstate(13)=y
   end
 
end
 
endfunction
 
