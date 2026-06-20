function prt_meth_n_endo(res,out)
 
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
 
write(out,meth+' estimation results for endogenous: '+res('namey'))
nchars=length(meth+' estimation results for endogenous: '+res('namey'))
stars=strcat(emptystr(1,nchars)+'*')
write(out,stars)
write(out,' ')
 
 
endfunction
