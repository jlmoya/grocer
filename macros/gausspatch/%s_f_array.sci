function array=%s_f_array(num,array)
  
[nr_num,nc_num]=size(num)
array('value')=[num ; array('value')]     
     
array('text')=[emptystr(nr_num,nc_num) ; array('text')]

endfunction
