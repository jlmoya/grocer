function []=prtauto_multi(results,namemod,test,path,output)
 
// PURPOSE: prints the sub-results named namemod in a tlist
// provided by automatic when there can be several regressions
// in the namemod field
// ------------------------------------------------------------
// INPUT:
// * results = a tlist results from automatic()
// * namemod = the name of the sub-results to print in the
//   results tlist
// * test = %t if the user wants to print the specification
//          tests results ; %f if not
// * path = %t if the user wants to print the name of the
//   successively eliminated variables that lead to the printed
//   models
// * output = the file where the results are printed
// ------------------------------------------------------------
// OUTPUT: nothing, only prints results
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2005
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
select nargin
case 2 then
   test=%f
   path=%f
   output=%io(2)
case 4 then
   output=%io(2)
end
listr=results(1)
 
select namemod
case 'stage 1 models' then
   if(and(listr ~= 'stage 1 models')) then
      warning('there is no stage 1 model to display')
      return
   else
      namex=results('initial model')('namex')
   end
case 'stage 2 models' then
   if(and(listr ~= 'stage 2 models')) then
      warning('there is no stage 2 model to display')
      return
   else
   namex=results('stage 2.0 model')('namex')
   end
end
 
write(output,namemod)
write(output,' ')
r=results(evstr(''''+namemod+''''))
for i=1:length(r)/3
   write(output,'model #'+string(i))
   write(output,' ')
   if path then
      vecpath=r(3*i-2)
         if part(vecpath(1),1:14) ~= 'variables with' then
            write(output,'successively eliminated variables:')
        end
      for j=1:size(vecpath,'*')
        write(output,vecpath(j))
      end
      write(output,' ')
   end
   ri=r(3*i)
   for j=1:size(results('comp'),2)
      ri('namex')(j)=ri('namex')(j)+'(*)'
   end
   prtuniv(ri,output)
   m2prt=[]
   if test then
      write(output,'tests results:')
      write(output,'**************')
      m=['test value' 'p-value']
      m=[m ; string(ri('spec_test')) ]
      m2prt=[ri('m_test') m ]
   end
   if namemod == 'stage 2 models' then
      col1=[' ' ; 'aic' ; 'bic' ;'hq' ]
      col2=[' ' ; string([ri('aic');ri('bic');ri('hq')])] ;
      col3=' '+emptystr(4,1)
      m2prt=[m2prt ; [col1, col2 , col3] ]
   end
   if m2prt ~= [] then
      printmat(m2prt,output)
      write(output,' ')
   end
end
printsep(output)
 
endfunction
