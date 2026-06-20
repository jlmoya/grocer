function prtuniv_coeffs(res,out)

bet=res('beta')
namex=res('namex')
write(out,[' '])
mat2print=['variable' 'coeff' 't-statistic' 'p value']
	
for i=1:nvar
   mat2print=[mat2print ; namex(i) string(bet(i)) string(res('tstat')(i)) string(res('pvalue')(i))]
end
 
if meth == 'ADF' | meth == 'ers' then
   mat2print(2,4) = '(*)'
elseif meth == 'olsecm' then
   mat2print($,4) = '(*)'
elseif meth == 'ar(1) maximum likelihood'
   mat2print=[mat2print ; emptystr(1,4)+' ' ; 'rho' string([res('rho') res('trho') (1-cdfnor("PQ",abs(res('trho')),0,1))*2]) ]
end
 
printmat(mat2print,out)

grocer_comp=0
for i=1:size(namex,1)
   l=length(namex(i))
   m=part(namex(i),max(l-2,1):l)
   if m == '(*)' then
      grocer_comp=grocer_comp+1
   end
end

if grocer_comp == 1 then
   write(out,'(*): variable constrained by the user to be present in the regression')
elseif grocer_comp > 1 then
  write(out,'(*): variables constrained by the user to be present in the regression')
end

endfunction
