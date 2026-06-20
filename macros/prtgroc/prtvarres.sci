function []=prtvarres(res,out)
 
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
namey=res('namey')
namex=res('namex')
bet=res('beta')
tstat=res('tstat')
pvalue=res('pvalue')
meth=res('meth')
 
write(out,' ')
write(out,res('meth')+' estimation results for variables')
str2print=namey(1)
for i=2:neqs-1
   str2print=str2print+', '+namey(i)
end
str2print=str2print+' and '+namey(neqs)
write(out,str2print)
write(out,' ')
 
write(out,'AIC criterion: '+string(res('aic')))
write(out,'BIC criterion: '+string(res('bic')))
write(out,'Hannan-Quinn criterion: '+string(res('hq')))
write(out,' ')
 
if res('prests') then
   boundsvar=res('bounds')
   ch='estimation period: '
   for j=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*j-1)+'-'+boundsvar(2*j)+'  '
   end
   write(out,ch)
end
write(out,' ')
 
namex_short=part(namex,1:5)
grocer_comp=0
for i=1:size(namex,1)
   l=length(namex(i))
   m=part(namex(i),max(l-2,1):l)
   if m == '(*)' then
      grocer_comp=grocer_comp+1
   end
end
 
 
for i=1:neqs
   write(out,'estimation results for dependent variable '+string(namey(i)))
   ind_eqi=[find(namex_short == 'eq '+string(i)+'.')]
   write(out,'number of observations: '+string(res('nobs')))
   write(out,'number of variables: '+string(nvar(i)))
   write(out,'standard error of the regression: '+string(res('ser')(i)))
   write(out,'sum of squared residuals: '+string(res('sigma')(i,i)))
   write(out,'DW(0) ='+string(res('dw')(i)))
   write(out,[' '])
 
   if isempty(ind_eqi)  then
      write(out,'no estimated coefficient for this endogenous variable')
   else
      namexi=strsubst(namex(ind_eqi),'eq '+string(i)+'.','')
      mat2print=['variable' 'coeff' 't-statistic' 'p value' ; ...
                 namexi string([bet(ind_eqi) tstat(ind_eqi) pvalue(ind_eqi)])]
      printmat(mat2print,out)
   end
 
   if grocer_comp == 1 then
      write(out,'(*): variable constrained by the user to be present in the regression')
   elseif grocer_comp > 1 then
      write(out,'(*): variables constrained by the user to be present in the regression')
   end
 
   printsep(out)
end
 
endfunction
