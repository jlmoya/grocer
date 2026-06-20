function [results]=test_spec(results,varargin)
 
// PURPOSE: provide standard specification tests
// ------------------------------------------------------------
// INPUT:
// * results = a tlist results from a univariate estimation
// function
// * varargin = a string wich can be
//    . 'nar = XX' : number for ARLM test
//    . 'noprint' : if the user doen't want to print the result
// ------------------------------------------------------------
// OUTPUT:
// * results = the same tlist but with the results of standard
//  specification tests
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004 / Emmanuel Michaux 2006
// http://grocer.toolbox.free.fr/grocer.html
 
 
// set defaults
grocer_nar = 4
n1 = round(0.5*results('nobs'))
n2 = round(0.9*results('nobs'))
grocer_prt=%t
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
 
   if typeof(varargin(grocer_i)) == 'string' then
      argi=strsubst(varargin(grocer_i),' ','')
      str3=part(argi,1:3)
      if str3 == 'nar' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif argi == 'noprint' then
         grocer_prt=%f
      end
 
   else
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
nvarmax = floor(0.5*results('nobs'))
[v,p] = test_spec0(results)
results(1)($+1) = 'name_test'
results('name_test') = ['test' ;...
      'Chow pred. fail. (50%)';...
      'Chow pred. fail. (90%)' ; ...
      'Doornik & Hansen' ;'AR(1-'+string(grocer_nar)+')' ; 'hetero x_squared']
results(1)($+1) = 'spec_test'
results('spec_test') = [v p]
 
if grocer_prt then
   prt_test(results,%io(2))
end
endfunction
