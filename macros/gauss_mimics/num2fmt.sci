function formated_num=num2fmt(num,fmt_number,prec)
    
if fmt_number == 'lf' | fmt_number == 'd' then
   formated_num=format_dec(num,prec(1))

elseif fmt_number == 'le' | fmt_number == 'e' then
   formated_num=format_exp(num,prec(1))

elseif fmt_number == 'o' then   
   fmt_d=format_dec(num,prec(1))
   fmt_e=format_exp(num,prec(1))
   ld=length(fmt_d)
   le=length(fmt_e)
   if ld <= le then
      formated_num=fmt_d
   else
      formated_num=fmt_e
   end

elseif fmt_number == 'lg' | fmt_number == 'z' then   
   [fmt_d1,fmt_d2]=format_dec(num,prec(1))
   [fmt_e1,fmt_e2]=format_exp(num,prec(1))
   ld=length(fmt_d2)
   le=length(fmt_e2)
   if ld <= le then
      formated_num=fmt_d2
   else
      formated_num=fmt_e2
   end
   
end    

endfunction