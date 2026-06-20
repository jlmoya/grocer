function ind_keywds=sci_find_simple(statk,keywd,preced)
 
// PURPOSE: in a string, find the indexes of a keyword
// ------------------------------------------------------------
// INPUT:
// * statk = a string
// * keywd = a string, the keywod to locate
// * preced = a scalar, the precedence attributed to the
//   keyword
// ------------------------------------------------------------
// OUTPUT:
// * ind_keywds = the original matrix extended with the
//   keywords found in the statement component
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
ind_keywds=strindex(statk,keywd)
ind_keywds=[ind_keywds ; length(keywd)*ind_keywds./ind_keywds ; ...
preced*ind_keywds./ind_keywds ]
 
endfunction
 
