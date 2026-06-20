function x=rndi(r,c)
 
// PURPOSE: mimics gauss function rdni: resets the generator
// seed
// ------------------------------------------------------------
// INPUT:
// * r = scalar
// * c = scalar
// ------------------------------------------------------------
// OUTPUT:
// * x = new seed
// ------------------------------------------------------------
// NOTE:
// This is not exactly the gauss function since the random
// generator is not the same
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
grand('setgen','mt')
if ~exists('grocer_gauss_seed') then
   global grocer_gauss_seed
   grocer_gauss_seed=getdate('s')
   grand('setsd',grocer_gauss_seed)
end
x=grand(r,c,'lgi')
 
endfunction
