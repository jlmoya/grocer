function %results_p(results)
 
// PURPOSE: function to replace the display of a whole results
// tlist by the message: "method estimation result"
// ------------------------------------------------------------
// INPUT:
// * a results tlist
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
write(%io(2),results('meth')+' estimation results','(a)')
 
endfunction
 
