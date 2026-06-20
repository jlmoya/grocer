function [gcond,noncond]=cond_varspec(name)
 
// PURPOSE: define the vector of conditions relative to the
// special names in a regression
// ------------------------------------------------------------
// INPUT:
// * name = a string, the name of an object (typically used in
//   a regression)
// ------------------------------------------------------------
// OUTPUT:
// * gcond = the list of conditions that a variable must check
//   to be a specific one (one of them)
// * noncond = the list of conditions that a variable must check
//   not to be a specific one (all of them)
// ------------------------------------------------------------
// NOTE : this function goes hand in hand with the function
// deal_varspec that transforms the names into the corresponding
// vector of values
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
 
gcond=[name+'==''const''';name+'==''cte''';name+'==''trend''';...
'part('+name+',1:6)==''trend^''';...
'~isempty(strindex('+name+',''post(''))';...
'~isempty(strindex('+name+',''dummy(''))']
 
noncond=[name+'~=''const''';name+'~=''cte''';name+'~=''trend''';...
'part('+name+',1:6)~=''trend^''';...
'isempty(strindex('+name+',''post(''))';...
'isempty(strindex('+name+',''dummy(''))']
 
endfunction
