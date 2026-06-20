function array=%array_f_c(array,str)
  
[nr_str,nc_str]=size(str)
array('value')=[array('value') ; %nan*ones(nr_str,nc_str)]     
     
array('text')=[array('text') ; str]

endfunction
