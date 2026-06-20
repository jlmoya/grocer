function []=prtsp(res,out)
 
// PURPOSE: prints the results of the Schmidt-Phillips test
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
write(out,' ')
write(out,'Schmidt-Phillips unit root test for variable: '+res('namey'))
write(out,'with a polynomial of order '+string(res('t')))
write(out,' ')
r1=res('rho')
nst=0
r=emptystr()
if r1 < res('cv_rho_10%') then
   r='(*'
   nst=10
   if r1 < res('cv_rho_5%') then
      r=r+'*'
   nst=5
   end
   if r1 < res('cv_rho_1%') then
      r=r+'*'
   nst=1
   end
   r=r+')'
end
rd=string(r1)+r
 
mat2print=['rho' '1% critical value' '5% critical value' '10% critical value';...
            rd string(0.01*int([res('cv_rho_1%') res('cv_rho_5%') res('cv_rho_10%')]*100))]
printmat(mat2print,out)
write(out,' ')
if nst ~= 0 then
   write(out,r+' significant at the '+string(nst)+'% level')
end
r1=res('tau')
nst=0
r=emptystr()
if r1 < res('cv_tau_10%') then
   r='(*'
   nst=10
   if r1 < res('cv_tau_5%') then
      r=r+'*'
   nst=5
   end
   if r1 < res('cv_tau_1%') then
      r=r+'*'
   nst=1
   end
   r=r+')'
end
rd=string(r1)+r
 
write(out,' ')
write(out,' ')
mat2print=['tau' '1% critical value' '5% critical value' '10% critical value';...
            rd string(0.01*int([res('cv_tau_1%') res('cv_tau_5%') res('cv_rho_10%')]*100))]
printmat(mat2print,out)
write(out,' ')
if nst ~= 0 then
   write(out,r+' significant at the '+string(nst)+'% level')
end
 
printsep(out)
endfunction
