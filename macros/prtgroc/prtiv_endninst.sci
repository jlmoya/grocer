function prtiv_endninst(res,out)

nendo=size(res('nameendo'),'*')
if nendo ==0 then
    if meth == 'threesls' then
       write(out,'there is no endogenous variable in the equation')
    else
       write(out,'there is no endogenous variable in the equation: iv=ols')
    end
else
   if nendo == 1  then
      write(out,'endogenous variable in this equation is:')
   else
      write(out,'endogenous variables in this equation are:')
   end
   write(out,strcat(res('nameendo'),','))
   write(out,' ')
   if size(res('nameinst'),'*') == 1 then
      write(out,'instrument for this equation is:')
   else
      write(out,'instruments for this equation are:')
   end
   write(out,strcat(res('nameinst'),','))
   write(out,' ')
   if nendo == 1  then
      write(out,'first stage F statistics is:')
      write(out,string(res('first stage F')))
   else
      write(out,'first stage F statistics are:')
      write(out,strcat(string(res('first stage F')),' - '))
   end
   
end
write(out,' ')

endfunction
