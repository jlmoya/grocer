function r=%s_f_c(num,str)
  
[nr_str,nc_str]=size(str)
[nr_num,nc_num]=size(num)
     
r=tlist(['array';'value';'text'],[num ; %nan*zeros(nr_str,nc_str)],[emptystr(nr_num,nc_num) ; str])
     
endfunction
