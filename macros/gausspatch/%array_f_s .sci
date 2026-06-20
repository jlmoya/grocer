function array=%array_f_s(array,num)
  
[nr_num,nc_num]=size(num)
array('value')=[array('value'),num]     
     
array('text')=[array('text');emptystr(nr_num,nc_num)]

endfunction
