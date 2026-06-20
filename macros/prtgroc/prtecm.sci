function []=prtecm(res,out)
 
// PURPOSE: prints the results of a Johansen cointegration test
// on the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a johansen regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following function:
// johansen()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
raux=res
namey=raux('namey')
for i=1:size(namey,1)
   namey(i)=part(namey(i),5:length(namey(i))-1)
end
raux('namey')=namey
nbr=raux('nb_coint_relat')
write(out,' ')
 
if nbr ~= 0 then
   jres=res('jres')
   name_st=jres('namexo_st')
   if name_st($) == res('namexo_lt')($) then
      write(out,'*** error correction vectors used in the '+res('meth')+' ***')
      write(out,' ')
      mat2prt=['variable' 'vector # '+string(1:nbr)+' ';...
           [res('namey'); res('namexo_lt')] string(res('evec')(:,1:nbr))]
      printmat(mat2prt,out)
      write(out,' ')
   end
end
printsep(out)
prtvar(res,%io(2))
 
endfunction
