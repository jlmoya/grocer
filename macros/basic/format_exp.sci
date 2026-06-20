function [fmt_e1,fmt_e2]=format_exp(num,fmt_dec)
 
// PURPOSE: format a number in exponentiated format with a
// predefined number of decimal terms
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
 
num_int=round(num)
num_sign=strsubst(string(sign(num)),'1','')
if num ==0 then
//   num_int_ndigits=max(floor(log10(abs(num))))+1
   num_exp=0
else
//   num_int_ndigits=max(floor(log10(abs(num))))+1
   num_exp=floor(log10(abs(num)))
end
num_befexp=string(round(abs(num) .* 10.^(fmt_dec-num_exp))./10.^(fmt_dec))
num_dec1=part(num_befexp,strindex(num_befexp,'.')+1:length(num_befexp))
if length(num_dec1) < fmt_dec then
   addon=strcat('0'+emptystr(fmt_dec-length(num_dec1),1))
else
   addon=''
end
num_befexp2=num_befexp+addon
 
num_exp2prt=string(num_exp/1000)
num_exp2prt(num_exp2prt == '0')='000'
num_exp2prt='+'+num_exp2prt
num_exp2prt=strsubst(num_exp2prt,'+-','-')
num_exp2prt=strsubst(num_exp2prt,'0.','')
fmt_e1=num_sign+num_befexp2+'E'+num_exp2prt
fmt_e2=num_sign+num_befexp+'E'+num_exp2prt
 
 
endfunction
