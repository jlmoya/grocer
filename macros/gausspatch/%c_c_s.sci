function r=%c_c_s(str,num)
  
[nr_str,nc_str]=size(str)
[nr_num,nc_num]=size(num)
     
r=tlist(['array';'value';'text'],[%nan*zeros(nr_str,nc_str),num],[str,emptystr(nr_num,nc_num)])

endfunction
