function []=prtuniv(res,varargin)
 
// PURPOSE: prints the results of univariate regression on
// the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR;
 
load(GROCERDIR+'\param\prt_foo.dat')
meth=res('meth')
ind_foo=find(meth == prtuniv_foo(:,1)')
if isempty(ind_foo) then
   select meth
   case 'auto' then
      prtauto(res,list(),out)
   end
   error(meth+': not an available method for prtuniv')
else
   execstr(prtuniv_foo(ind_foo,2)+'(res,varargin(:))')
end
 
endfunction
