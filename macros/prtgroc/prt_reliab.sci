function prt_reliab(res,out)
 
// PURPOSE: prints the results of a reliability diagnostic
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a reliability diagnostic
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2006
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
write(out,'reliability tests:')
write(out,'------------------')
if typeof(res) == 'string' then
   write(%io(2),' ','(a)')
   write(out,res)
else
   reliab=res('reliab')
   // restrict namex to the variables tested (case of panel estimation methds)
   namex=res('namex')(1:size(reliab,1))
   m2prt=['variable' 'reliability' ; ' ' ' ' ; namex string(reliab) ]
   printmat(m2prt,out)
end
 
endfunction
