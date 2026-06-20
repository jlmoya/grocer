function []=expvec2exc(grocer_vec,grocer_output,grocer_sep,transpose)
 
// PURPOSE: export the content of a data base or a list of
// variables bd to a file that Excel can read
//-------------------------------------------------------------
// INPUT:
// * grocer_bd = the name of a database or of a list of ts
// loaded in the environment
// * grocer_output = the excel file where to save the data
// * sep = decimal separator (optional: if not given then sep= '.')
// * transpose=anything but optional: if given then series are
//   exported in rows instead of columns
//-------------------------------------------------------------
// OUTPUT:
// nothing
//-------------------------------------------------------------
// Copyright Eric Dubois 2006
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 2 then
   grocer_sep='.'
end
 
grocer_m2tobexported=[grocer_vec ; string(evstr(grocer_vec))]
 
sci2excel(grocer_m2tobexported,grocer_output)
 
endfunction
 
