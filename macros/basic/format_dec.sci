function [fmt_d1,fmt_d2]=format_dec(num,fmt_dec)
 
// PURPOSE: format a number in decimal format with a predefined
// number of decimal terms
// ------------------------------------------------------------
// INPUT:
// * num = a real number
// * fmt_dec = # of decimal terms
// ------------------------------------------------------------
// OUTPUT:
// * str = the transformed string matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
num_int=int(num)
num_sign=strsubst(string(sign(num)),'1','')
num_dec1=string(round(abs(num-num_int) .* 10.^(fmt_dec+1))./10.^(fmt_dec+1))
if length(num_dec1) < fmt_dec+2 then
   addon=strcat('0'+emptystr(fmt_dec+2-length(num_dec1),1))
else
   addon=''
end
num_dec2=num_dec1+addon
 
if fmt_dec == 0 then
   fmt_d1=num_sign+strsubst(string(num_int),'-','')
   fmt_d2=fmt_d1
else
   fmt_d1=num_sign+strsubst(string(num_int),'-','')+'.'+part(strsubst(string(num_dec1),'-',''),3:fmt_dec+2)
   fmt_d2=num_sign+strsubst(string(num_int),'-','')+'.'+part(strsubst(string(num_dec2),'-',''),3:length(num_dec2))
end
 
endfunction
