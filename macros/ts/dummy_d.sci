function [dum1,dum2]=dummy_d()
 
// demo of function dummy
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
// dummy on a lone date
 
 
dum1=dummy(['1970q1','1979q4'],'1973q4')
// dummy on a dates range
dum2=dummy(['1970q1','1979q4'],['1971q1','1972q2'])
 
endfunction
