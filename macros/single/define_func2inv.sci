function []=define_func2inv(grocer_func,grocer_invfunc)
 
// PURPOSE: save into the database functions.dat a string
// vector of functions and a string of the inverse of these
// functions
// ------------------------------------------------------------
// INPUT:
// * grocer_func = a string vector of functions
// * grocer_iunvfunc = a string vector of the inverse of these
//   functions
// ------------------------------------------------------------
// OUTPUT:
// nothing
// ------------------------------------------------------------
// NOTE:
// the only interest of this function (with respect to the
// instruction it represents) is to avoid remembering the name
// of the database
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009-2020
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
save(GROCERDIR+'/data/functions.dat','grocer_func','grocer_invfunc')
 
endfunction
