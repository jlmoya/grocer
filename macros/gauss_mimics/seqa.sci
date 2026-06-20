function [seq]=seqa(a,b,c)
 
// PURPOSE: produce a sequence of values
// -----------------------------------------------------
// INPUT:
// a = initial value in sequence
// b = increment
// c = number of values in the sequence
// -----------------------------------------------------
// OUTPUT:
// a sequence, (a:b:(a+b*(c-1)))' in scilab notation
// -----------------------------------------------------
// NOTE: a Gauss compatibility function
// -----------------------------------------------------
// translated by Eric Dubois from:
// http://grocer.toolbox.free.fr/grocer.html
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
// seqa Gauss eqivalent of seqa(a,b,c)
seq = (a:b:a+b*(c-1))';
 
endfunction
 
