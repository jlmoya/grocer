function %params_p(params)
 
// PURPOSE:
// ------------------------------------------------------------
// INPUT:
// * params = the param field from a model tlist
// ------------------------------------------------------------
// OUTPUT:
// NOTHING: the functiion is used only for display purposes
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015-2016
// http://grocer.toolbox.free.fr/grocer.html
 
if length(params) == 1 then
   write(%io(2),'no params in model','(a)')
else
   params_1=params(1)(2:$)
   nparams=size(params_1,1)
   params_2=emptystr(nparams,1)
   for i=1:size(params_1,1)
      if ~isempty(params(i+1)) then
         params_2(i)=string(params(i+1))
      end
   end
   mat2prt=[params_1 , params_2]
   printmat(mat2prt,%io(2))
end
 
endfunction
