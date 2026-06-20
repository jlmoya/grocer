function prtjohan_eigen_ecm(res,out)
 
// PURPOSE: prints eigen vectors, their weights and the
// combined effects from a johansen estimation
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a johansen regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
     out=%io(2)
end
 
write(out,' ')
write(out,'eigen vectors')
write(out,'*************')
write(out,' ')
mat2prt=['variable\vector' string([1:res('nvar')]) ;...
' '+emptystr(1,res('nvar')+1) ;...
[res('namey') ; res('namexo_lt')] string(res('evec')) ]
 
printmat(mat2prt,out)
write(out,' ')
 
write(out,'weights to the eigen vectors')
write(out,'****************************')
mat2prt=['equation for\eigen vector' string([1:res('nvar')]) ;...
' '+emptystr(1,res('nvar')+1) ;...
'Delta('+res('namey')+')'  string(res('alpha'))' ]
 
printmat(mat2prt,out)
write(out,' ')
 
write(out,'combined effects')
write(out,'****************')
mat2prt=['equation for\long term variable' [res('namey') ; res('namexo_lt')]' ;...
' '+emptystr(1,res('nvar')+size(res('namexo_lt'),1)+1) ;...
'Delta('+res('namey')+')' string(res('pi'))' ]
 
printmat(mat2prt,out)
write(out,' ')
 
 
endfunction
