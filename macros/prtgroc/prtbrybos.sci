function prtbrybos(res,out)
 
// PURPOSE: prints the results of a Bry-Boschan dating rules
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following function:
//	bryboc()
// ---------------------------------------------------
// Copyright E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
if res('meth') == 'hp' then
   meth = 'Harding-Pagan'
else
   meth = 'Bry-Boschan complete procedure'
end
 
write(out,' ')
write(out,'Turning points dating results of '+string(res('namey')))
write(out,'Method: '+meth)
if res('meth') == 'hp'
   write(out,'Transformation: '+string(res('filter')))
end
 
ch='Estimation period: '
boundsvar=res('bounds')
for i=1:size(boundsvar,1)/2
   ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+'  '
end
write(out,ch)
 
write(out,' ')
 
// determine first turning-point
if isempty(res('P')) then
   firstP=0
   warning('no peak')
else
   firstP = date2num(res('P')(1))
end
if isempty(res('T')) then
   warning('no through')
   firstT=0
else
   firstT = date2num(res('T')(1))
end
if firstP-firstT>0 then
   first = res('T')
   second = res('P')
   mat2print = ['Troughs' , 'Peaks ' ]
else
   first = res('P')
   second = res('T')
   mat2print = ['Peaks ' , 'Troughs']
end
 
nf = size(first,1)
ns = size(second,1)
if nf > ns then
   second = [second; ' ']
elseif nf < ns then
   first =  [first; ' ']
end
 
mat2print = [mat2print ; first second]
printmat(mat2print,out)
 
write(out,'')
write(out,'Cycle caracteristics:')
write(out,'Average duration from peak to peak: '+string(res('DPP')))
write(out,'Average duration from trough to trough: '+string(res('DTT')))
write(out,'Average duration from peak to trough: '+string(res('DPT')))
write(out,'Average duration from trough to peak: '+string(res('DTP')))
write(out,'Average amplitude from peak to trough: '+string(res('APT')))
write(out,'Average amplitude from trough to peak: '+string(res('ATP')))
 
printsep(out)
endfunction
