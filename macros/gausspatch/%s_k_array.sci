function array=%s_k_array(num,array)
  
array_txt=array('text')
array_val=array('value')
array('value')=num .*. array_val
array_txtcol=[]
for j=1:size(num,2)
   array_txtcol=[array_txtcol array_txt]
end
array_txtnew=[]
for i=1:size(num,1)
   array_txtnew=[array_txtnew ; array_txtcol]
end
array('text')=array_txtnew
      
     
endfunction
