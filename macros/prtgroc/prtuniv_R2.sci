function prtuniv_R2(res,meth,nvar,out)

if part(convstr(getversion()),1:9) == 'scilab-5.' then
   matspec=[' ' ' ']
else
   matspec=' '
end
if res('prescte')  & nvar > 1 then
   if meth == 'twosls' | meth == 'threesls' | meth == 'iv'  then
      matspec(1)='generalized R2 = '+string(res('grsqr'))+'  adjusted generalized R2 ='+string(res('grbar'))
   else
      matspec(1)='R2 = '+string(res('rsqr'))+'  adjusted R2 ='+string(res('rbar'))
   end
   write(out,matspec)
   fi="Overall F test: F("+string(nvar-1)+","+string(res('nobs')-nvar)+...
   ") = "+string(res('f'))+"       p-value = "+string(res('pvaluef'))
   write(out,fi)
end
    
    
endfunction