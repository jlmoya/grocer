function []=prthaussman(res,out)
 
// PURPOSE: prints the results of a Haussman test on panel
// results
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
 
m=res('stat')
p=res('pvalue')
write(out, ' ')
write(out,'***** Haussman Test *******');
write(out,'Ho: Random Effects');
write(out,'Ha: Fixed Effects');
write(out,'Statistic = '+string(m));
write(out,'P-value = '+string(p));
write(out,'***************************');
endfunction
