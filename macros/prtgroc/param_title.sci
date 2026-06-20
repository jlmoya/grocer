function [font_title] = param_title(title)
 
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
 
lengthtitle=max(length(title))
thresh=11
maxcar=12
font_title=min(maxcar,maxcar-floor(lengthtitle/thresh))
font_axis=4
ref_nbinter=60
 
endfunction
