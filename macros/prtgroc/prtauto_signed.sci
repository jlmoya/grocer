function prtauto_signed(res,lnp,output)
 
// PURPOSE: prints the results of automatic_signed() along the
// options given by the user and stored in lnp
// ------------------------------------------------------------
// INPUT:
// * results = a tlist provided by automatic
// * lnp = the list of options provided by the user
// * output = the file where to print the results
// ------------------------------------------------------------
// OUTPUT:
// nothing, just print the results
// ------------------------------------------------------------
// NOTES: used by automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2011
// http://grocer.toolbox.free.fr/grocer.html
 
if lnp == 'final' then
   write(%io(2),' ','(a)')
   write(%io(2),'removed variables','(a)')
   write(%io(2),'-----------------','(a)')
   write(%io(2),' ','(a)')
   removed_var=res('removed var')
   if ~isempty(removed_var) then
      printmat(removed_var,%io(2))
      write(%io(2),' ','(a)')
   else
      write(%io(2),'none','(a)')
   end
end
 
prtauto(res('final automatic'),lnp,%io(2))
 
endfunction
