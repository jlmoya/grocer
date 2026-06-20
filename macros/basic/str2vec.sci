function [grocer_s]=str2vec(grocer_name,varargin)
 
// PURPOSE: given a string 'xxx=yy1 sep ... sep yyn', define
// the vector ['yy1';...;'yyn']
// ------------------------------------------------------------
// INPUT:
// * grocer_name = a string
// * varargin = any string representing a separator
//   (default : ';')
// ------------------------------------------------------------
// OUPTUT:
// grocer_s = a (n x 1) vector of names
// ------------------------------------------------------------
// NOTE:
// used by nls(), sur(), twosls(), threesls()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_name=strsubst(grocer_name,'''','''''')
grocer_nargin=length(varargin)
if grocer_nargin == 0 then
   grocer_name='grocer_'+strsubst(grocer_name,';',''';''')
else
   for grocer_i=1:grocer_nargin
      grocer_sep=varargin(grocer_i)
      grocer_name=strsubst(grocer_name,grocer_sep,''';''')
   end
end
grocer_name=strsubst(grocer_name,'=','=[''')
grocer_name=grocer_name+''']'
grocer_name=strsubst(grocer_name,'[''[','[''')
grocer_name=strsubst(grocer_name,']'']',''']')
 
execstr(grocer_name)
execstr('grocer_s='+part(grocer_name,1:strindex(grocer_name,'=')-1))
 
endfunction
 
