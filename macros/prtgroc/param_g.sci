function [] = param_g(ref_nbinter,thresh,font_axis)
 
// PURPOSE: determines the size of the title chars
// ------------------------------------------------------------
// INPUT:
// title = title of a graph
// ------------------------------------------------------------
// OUPTUT:
// font_title = size of the title chars
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
 
global GROCERDIR;
 
[nargout,nargin]=argn(0)
if nargin == 0 then
   load(GROCERDIR+'/param/param_g.dat')
   mat2prt=['maximum number of characters on the x axis:' string(ref_nbinter) ;...
            'maximum number of chacracters of the title with size 5:' string(thresh);...
            'font used for the axes:' string(font_axis)]
            printmat(mat2prt,%io(2))
else
   save(GROCERDIR+'/param/param_g.dat','ref_nbinter','thresh','font_axis')
end
 
endfunction
