function %modelg_p(model)
 
// PURPOSE: function to replace the display of a whole model
// tlist by the message: "[name-of-model] model tlist"
// ------------------------------------------------------------
// INPUT:
// * a model tlist
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015
// http://grocer.toolbox.free.fr/grocer.html
 
if isempty(model('namemod')) then
   write(%io(2),' model without name ','(a)')
end
write(%io(2),model('namemod')+' model tlist','(a)')
 
endfunction
 
