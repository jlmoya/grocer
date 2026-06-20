function []=prtjohvec(res,nbr,out)
 
// PURPOSE: prints the results of the first nbr cointegration
// vectors
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a johansen regression
// * nbr = # cointegration vectors selected
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following function:
// ecm()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 2 then
   out=%io(2)
end
write(out,' ')
 
if nbr == 0 then
   write(out,'*** there is no cointegrating vector from johansen estimation ***')
else
   write(out,'*** cointegrating vectors from Johansen estimation ***')
   write(out,' ')
   mat2prt=['variable' 'vector # '+string(1:nbr)+' ';...
           [res('namey'); res('namexo_lt')] string(res('evec')(:,1:nbr))]
   printmat(mat2prt,out)
   write(out,' ')
end
printsep(out)
 
endfunction
