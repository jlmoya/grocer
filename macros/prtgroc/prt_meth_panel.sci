function [panhac,panmbb]=prt_meth_panel(res,out)
 
// PURPOSE: prints the header of an estimation method on file
// out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list from an olsmod regression
// * out = the symbolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
panhac=%f
panmbb=%f
write(out,meth+' estimation results for endogenous: '+res('namey'))
if or(fieldnames(res)=='hac') then
   panhac=%t
   write(out,'with '+res('hac')+' HAC covariance matrix')
   if res('hac')=='moving blocks bootstrap' then
      panmbb=%t
   end
end
 
nchars=length(meth+' estimation results for endogenous: '+res('namey'))
stars=strcat(emptystr(1,nchars)+'*')
write(out,stars)
write(out,' ')
 
 
endfunction
