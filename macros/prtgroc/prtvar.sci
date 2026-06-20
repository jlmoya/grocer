function []=prtvar(res,out)
 
// PURPOSE: prints the results of a var regression on the file
// out
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
// varf(), ecm(), bvar(), becm()
// ---------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
neqs=res('neqs')
nvar=res('nvar')
nlag=res('nlag')
namey=res('namey')
namex=res('namex')
bet=res('beta')
tstat=res('tstat')
pvalue=res('pvalue')
meth=res('meth')
nx=res('nx')
 
write(out,' ')
write(out,res('meth')+' estimation results for variables')
str2print=namey(1)
for i=2:neqs-1
   str2print=str2print+', '+namey(i)
end
str2print=str2print+' and '+namey(neqs)
write(out,str2print)
write(out,' ')
 
if or(meth == ['var' ; 'ecm' ; 'restricted var']) then
   write(out,'AIC criterion: '+string(res('aic')))
   write(out,'BIC criterion: '+string(res('bic')))
   write(out,'Hannan-Quinn criterion: '+string(res('hq')))
   write(out,' ')
else
   write(out,'PRIOR hyperparameters')
   write(out,'tightness = '+string(res('tight')))
   write(out,'decay = '+string(res('decay')))
   if max(size(res('weight'))) == 1 then
      write(out,'symetric weights based on '+string(res('weight')))
   else
      write(out,'symetric weights based on:')
      printmat(string(res('weight')),out)
   end
end
 
grocer_comp=0
for i=1:size(namex,1)
   l=length(namex(i))
   m=part(namex(i),max(l-2,1):l)
   if m == '(*)' then
      grocer_comp=grocer_comp+1
   end
end
 
if res('prests') then
   boundsvar=res('bounds')
   ch='estimation period: '
   for j=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*j-1)+'-'+boundsvar(2*j)+'  '
   end
   write(out,ch)
end
write(out,' ')
 
for i=1:neqs
   write(out,'estimation results for dependent variable '+string(namey(i)))
   write(out,'number of observations: '+string(res('nobs')))
   write(out,'number of variables: '+string(nvar))
   if res('prescte') then
      write(out,'R² = '+string(res('rsqr')(i))+'      adjusted R² ='+string(res('rbar')(i)))
      if meth ~= 'bvar' & meth ~= 'becm' then
         fi="Overall F test: F("+string(nvar-1)+","+string(res('nobs')-nvar)...
            +") = "+string(res('overallf')(i))+"       p-value = "+string(res('pvaluef')(i))
         write(out,fi)
      end
   end
   write(out,'standard error of the regression: '+string(res('ser')(i)))
   write(out,'sum of squared residuals: '+string(res('sigma')(i,i)))
   write(out,'DW(0) ='+string(res('dw')(i)))
   if meth == 'var' | meth == 'ecm' then
      write(out,'Belsley, Kuh, Welsch Condition index: '+string(res('condindex')(i)))
   end
   write(out,[' '])
   mat2print=['variable' 'coeff' 't-statistic' 'p value']
   ind=1
   for k=1:nlag
      for j=1:neqs
         mat2print=[mat2print ; namey(j)+'(-'+string(k)+')' string(bet(ind,i)) ...
                string(tstat(ind,i)) string(pvalue(ind,i))]
         ind=ind+1
      end
   end
 
   for j=1:nx
      mat2print=[mat2print ; string(namex(j)) string(bet(neqs*nlag+j,i)) ...
                string(tstat(neqs*nlag+j,i)) string(pvalue(neqs*nlag+j,i))]
   end
 
   printmat(mat2print,out)
 
   if grocer_comp == 1 then
      write(out,' ')
      write(out,'(*): variable constrained by the user to be present in the regression')
   elseif grocer_comp > 1 then
      write(out,' ')
      write(out,'(*): variables constrained by the user to be present in the regression')
   end
 
   printsep(out)
end
 
endfunction
