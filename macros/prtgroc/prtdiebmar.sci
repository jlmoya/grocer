function prtdiebmar(res,out)
 
// PURPOSE: prints the results of the Diebold-Mariano
// statistics
// ------------------------------------------------------------
// INPUT:
// * res = a results tlist
// * out = the file where the results are printed
// ------------------------------------------------------------
// out: nothing, only prints results
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux 2004 / 2006
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
write(out,' ')
if res('smallc') == 1 then
   write(out,'	Diebold-Mariano test')
else
   write(out,'	Diebold-Mariano test with small sample correction')
end
write(out,'')
write(out,'Benchmark series: '+res('namex')(1))
write(out,'Competing series: '+res('namex')(2))
write(out,'Truncation lag of the Barlett window:' +string(res('trunc')))
 
if res('prests') then
   ch='forecasting period: '
   boundsvar=res('bounds')
   for i=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+'  '
   end
   write(out,ch)
end
write(out,' ')
 
mat2print = ['Bench. MSE','Comp. MSE','DM-Stat.','p-value' ;...
              string(res('mse')(1)) string(res('mse')(2)) string(res('stat')) string(res('pvalue'))]
printmat(mat2print,out)
printsep(out)
endfunction
