function prtdchange(res,out)
 
// PURPOSE: prints the results of the Direction of change
// statistics
// ------------------------------------------------------------
// INPUT:
// * results = a results tlist
// * out = the file where the results are printed
// ------------------------------------------------------------
// OUTPUT:
// nothing, only prints results
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux 2005
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
write(out,'	Pesaran-Timmermann test of directional change')
write(out,'')
write(out,'H0 : '+res('namey')+' & '+res('nameyc')+' are independently distributed')
 
if res('prests') then
   ch='estimation period: '
   boundsvar=res('bounds')
   for i=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+'  '
   end
   write(out,ch)
end
write(out,' ')
 
mat2print = ['right propor. pred.' 'Stat. Sn' 'p-value' ;...
	    string(res('P')) string(res('stat')) string(res('pvalue'))]
printmat(mat2print,out)
printsep(out)
 
endfunction
