function prtuniv_block1(res,out)
    
if res('prests') then
   ch='estimation period: '
   boundsvar=res('bounds')
   for i=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+' '
   end
   if res('dropna') then
      ch=ch+'(NA values dropped)'
   end
   write(out,ch)
end

if res('meth') == 'saturated ols' then
   write(out,' ')
   write(out,'added dummies: '+res('significant dummies'))
   write(out,' ')
end

write(out,'number of observations: '+string(res('nobs')))
write(out,'number of variables: '+string(nvar))
    
    
    
endfunction
