function %array_p(array)

array_val=array('value')
array_str=array('text')

array2prt=string(array_val)
array2prt(isnan(array_val))=array_str(isnan(array_val))
printmat(array2prt,%io(2))

endfunction
