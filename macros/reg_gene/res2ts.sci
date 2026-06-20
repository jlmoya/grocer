function [tsout]=res2ts(grocer_res,grocer_nameobject)
 
// PURPOSE: transform into a ts an object in a results
// tlist according to the bounds saved in the tlist
// ------------------------------------------------------------
// INPUT:
// * grocer_res = a results tlist
// * grocer_nameobject = the name of a tlist field that can
//   be transformed into ts ('y','resid' or 'yhat')
// ------------------------------------------------------------
// OUTPUT:
// * tsout = the corresponding timeseries
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_obj = evstr('grocer_res('''+grocer_nameobject+''')')
boun = grocer_res('bounds')
tsout=vec2ts(grocer_obj,boun)
 
endfunction
