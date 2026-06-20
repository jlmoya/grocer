function prt_varcoeff(res,out)

// remove the 'VAR ' prefix from the names (case when
// the resulta come form function varwithfac
if res('meth') == 'var with factor' then
   prefix='VAR '
else
   prefix=''
end
nlag=res('nlag')
neqs=res('neqs')
namey=res('namey')
bet=res(prefix+'beta')
tstat=res(prefix+'tstat')
pvalue=res(prefix+'pvalue')
nvar=res(prefix+'nvar')
nx=res(prefix+'nx')
meth=res('meth')

for i=1:neqs
   write(out,'estimation results for dependent variable '+string(namey(i)))
   write(out,'number of observations: '+string(res('nobs')))
   write(out,'number of variables: '+string(nvar))
   if res(prefix+'prescte') then
      write(out,'R² = '+string(res(prefix+'rsqr')(i))+'      adjusted R² ='+string(res(prefix+'rbar')(i)))
      if meth ~= 'bvar' & meth ~= 'becm' then
        fi="Overall F test: F("+string(nvar-1)+","+string(res('nobs')-nvar)...
           +") = "+string(res(prefix+'overallf')(i))...
           +"       p-value = "+string(res(prefix+'pvaluef')(i))
         write(out,fi)
      end
   end
   write(out,'standard error of the regression: '+string(res(prefix+'ser')(i)))
   write(out,'sum of squared residuals: '+string(res(prefix+'sigma')(i,i)))
   write(out,'DW(0) ='+string(res(prefix+'dw')(i)))
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
      mat2print=[mat2print ; string(res(prefix+'namex')(j)) string(bet(neqs*nlag+j,i)) ...
                string(tstat(neqs*nlag+j,i)) string(pvalue(neqs*nlag+j,i))]
   end
   printmat(mat2print,out)
   printsep(out)
end


endfunction
