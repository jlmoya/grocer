function []=printsep(out);
 
// PURPOSE: prints a separator at the end of a printing to
// make the presentation of results clearer
// ------------------------------------------------------------
// INPUT:
// * out = the symobolic name of the file where the
//              results are printed
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// * used by the following functions:
// prtuniv()
// * the function should be adapted to the user's tastes and
// printing devices
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
write(out,' ')
write(out,'                         *')
write(out,'                      *     *')
write(out,' ')
endfunction
