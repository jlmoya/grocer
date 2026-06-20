function []=font_title(f,wind)
 
// PURPOSE: change the font of the title
// ------------------------------------------------------------
// INPUT:
// * f= size of the font
// * wind = number of an open window
// ------------------------------------------------------------
// OUPTUT:
// nothing: the current graphic window is modified
// ------------------------------------------------------------
// Copyright Jean-Baptiste Silvy/ Eric Dubois 2006
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 2 then
   scf(wind)
end
 
a = gca() ; // get the current axis
tit = a.title ; // get the handle of the title
tit.font_size = f ; // change the font_size
endfunction
