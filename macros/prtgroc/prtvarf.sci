function []=prtvarf(rvarf,out)
 
// PURPOSE: prints the results of a var forecast on
// the file out
// ------------------------------------------------------------
// INPUT:
// * rvarf = the results typed list of a johansen regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following function:
// varf()
// ---------------------------------------------------
// Copyright Eric Dubois 2002-2010
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
hforecast=rvarf('h forecast')
 
select rvarf('meth')
case 'varmaf' then
   meth='VARMA'+' '+rvarf('namevarma')
   rvar=rvarf('rvarma')
   namey=rvar('namey')
 
case 'msf' then
   meth='Markov Switching model'
   rvar=rvarf('r_ms')
   namey=rvar('namey')
 
case 'fac_kalmanf' then
   meth='Dynamic factor model'
   rvar=rvarf('rfac')
   nfactors=size(rvar('fac'),2)
   if nfactors == 1 then
      namey=[rvar('namey') ; 'factor']
   else
      namey=[rvar('namey') ; 'factor # '+string([1:nfactors]')]
   end
 
else
   meth='VAR'+rvarf('namevar')
   rvar=rvarf('rvar')
   if rvar('meth') == 'ecm' | rvar('meth') == 'becm' then
   // retrieve the true names of the variables
      namey=strsubst(rvar('namey'),'del(','')
      for i=1:rvar('neqs')
         namey(i)=part(namey(i),1:length(namey(i))-1)
      end
   else
      namey=rvar('namey')
   end
end
 
write(out,' ')
if typeof(hforecast) == 'string' then
   titl='forecasting results for the '+meth+' over the period '+...
   hforecast(1)+'-'+hforecast(2)
else
   titl='forecasting results for the '+meth+' at a ['+...
   string(hforecast(1))+';'+string(hforecast(2))+'] horizon'
end
write(out,titl)
stars=emptystr()
for i=1:length(titl)
   stars=stars+'*'
end
write(out,stars)
write(out,' ')
 
if rvar('prests') then
   obs=['obs\variable' ; num2date([date2num(hforecast(1)):date2num(hforecast(2))]',date2fq(hforecast(1)))]
else
   obs=['obs\variable' ; string([hforecast(1):hforecast(2)]')]
end
 
if rvarf('meth') == 'fac_kalmanf' then
   mat2print=[namey' ; string([rvarf('forecast') rvarf('fac forecast')])]
else
   mat2print=[namey' ; string(rvarf('forecast'))]
end
 
mat2print=[obs mat2print]
printmat(mat2print,out)
printsep(out)
endfunction
