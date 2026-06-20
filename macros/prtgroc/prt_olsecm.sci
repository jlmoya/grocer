function []=prt_olsecm(res,out)
 
// PURPOSE: prints the results of an ols, white, lad,
// Newey-West''s HAC', 'olst', 'ridge' regression on
// the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list from an olsmod regression
// * out = the symbolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
meth=res('meth')
prt_ols(res,out)
 
write(out,' ')
write(out,'............................................')
p=res('test p-value')
cr=res('test crit. value')
deter = res('deterministic')
select deter
case -1 then
   sd = 'no determnistic part';
case 0 then
   sd = 'constant';
case 1 then
   sd ='constant plus time-trend';
case 2 then
   sd ='constant plus quadratic time-trend';
end
write(out,'Type of determistic part in the cointegrating vector: '+sd)
 
if typeof(cr)=='string' then
   scr=cr;sp=p;
   p=evstr(part(p,3:length(p)));
else
   scr=string(cr);sp=string(p);
end
write(out,'Ericsson-MacKinnon critical value for ECM test is: '+scr)
write(out,'(*) approximate p-value for ECM test is: '+sp)
write(out,' ')
txt='conclusion: the null hypothesis of no-cointegration is '
 
if p < 0.01 then
   write(out,txt+'rejected at a 1% level')
elseif p < 0.05 then
   write(out,txt+'accepted at a 1% level, but rejected at a 5% level')
elseif p < 0.1 then
   write(out,txt+'accepted at a 5% level, but rejected at a 10% level')
else
    write(out,txt+'accepted even at a 10% level')
end
write(out,' ')
format(10)
 
 
endfunction
