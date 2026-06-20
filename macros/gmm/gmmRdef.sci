function fr = gmmRdef(parm,R)
 
// PURPOSE: Compute the value of the restrictions for
//		a nonlinear Wald test
// ------------------------------------------------------------
// INPUTS:
// . parm = value of the parameters
// . R = (s x 1) string vector of restrictions
// ------------------------------------------------------------
// OUTPUT:
// . fr a (s x 1) vector containing value of the constraints at parm value
// ------------------------------------------------------------
// E. Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
np = max(size(parm));
for i=1:np
  execstr('p'+string(i)+' = parm('+string(i)+')')
end
execstr('fr='+R);
endfunction
