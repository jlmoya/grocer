function []=prtauto_univ(results,namemod,test,output)
 
// PURPOSE: prints the sub-results named namemod in a tlist
// provided by automatic
// ------------------------------------------------------------
// INPUT:
// * results = a tlist results from automatic()
// * namemod = the name of the sub-results to print in the
//   results tlist
// * test = %t if the user wants to print the specification
//          tests results ; %f if not
// * output = the file where the results are printed
// ------------------------------------------------------------
// OUTPUT: nothing, only prints results
// ------------------------------------------------------------
// NOTE: used by prtauto()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 2 then
   test=%f
   output=%io(2)
end
if nargin == 3 then
   output=%io(2)
end
 
write(output,namemod)
write(output,' ')
if namemod == 'final model' then
   mat2print=['strategy' ': '+results('strategy');
              'F presearch significance level' ': '+string(results('f0_tdo')) ;
              't-test significance level' ': '+string(results('alpha')) ;
              'F test significance level' ': '+string(results('gam'))]
   eta=results('eta')
   if ~isempty(eta) then
      if and(eta == eta(1)) then
         mat2print=[mat2print ; 'specification tests significance level' ': '+string(eta(1))]
      else
         write(output,'specification tests significance level:')
         nametest=results('m_test')
         ntest=size(nametest,1)-1
         mat2print=[mat2print ; '  '+nametest(2:$) , ': '+string(eta) ]
      end
   end
   mat2print=[mat2print ; 'Information criterion' ': '+results('criterion')]
   printmat(mat2print,output)
   write(output,' ')
   write(output,'ending reason: '+results('ending reason'))
   write(output,' ')
end
 
if and(results(1) ~= namemod) then
   warning(' there is no '+namemod+' to display')
   return
else
   r=results(evstr(''''+namemod+''''))
end
 
for i=1:size(results('comp'),2)
   r('namex')(i)=r('namex')(i)+'(*)'
end
 
prtres(r,output)
 
if test & ~isempty(r('m_test')) then
   write(output,' ')
   write(output,'tests results:')
   write(output,'**************')
   m=['test value' 'p-value']
   m= [m ; string(r('spec_test'))]
   m2prt=[r('m_test') m]
   printmat(m2prt,output)
   write(output,' ')
   printsep(output)
end
 
if namemod == 'final model' then
   prt_reliab(results('reliab'),output)
   printsep(output)
end
 
endfunction
