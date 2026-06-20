function prt_test(results,output)
 
// PURPOSE: print the results of specification tests included
// in a results tlist
// ------------------------------------------------------------
// INPUT:
// * results = a results tlist
// * output = the file where the results are printed
// ------------------------------------------------------------
// OUTPUT: nothing, only prints results
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
write(output,' ')
write(output,'tests results:')
write(output,'**************')
m=['test value' 'p-value']
m= [m ; string(results('spec_test'))]
m2prt=[results('name_test') m]
printmat(m2prt,output)
write(output,' ')
printsep(output)
endfunction
